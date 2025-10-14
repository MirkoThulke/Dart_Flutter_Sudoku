/* 
##############################################################################

Author: MIRKO THULKE
Copyright (c) 2025, MIRKO THULKE
All rights reserved.

Date: 2025, VERSAILLES, FRANCE

License: "All Rights Reserved – View Only"

Permission is hereby granted to view and share this code in its original,
unmodified form for educational or reference purposes only.

Any other use, including but not limited to copying, modification,
redistribution, commercial use, or inclusion in other projects, is strictly
prohibited without the express written permission of the author.

The Software is provided "AS IS", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose, and noninfringement. In no event shall the
author be liable for any claim, damages, or other liability arising from the
use of the Software.

Contact: MIRKO THULKE (for permission requests)

##############################################################################
*/


/* 
✅ How this works
DartToRustElementFFI → raw struct for FFI, fixed-size arrays.
SerializableElement → JSON-friendly version with Vec<u8> instead of fixed-size arrays.
Conversion implemented via From.
Save → flatten the matrix → convert to SerializableElement → JSON → file.
Load → parse JSON → rebuild DartToRustElementFFI structs → copy back into Dart’s allocated memory.
Credits to ChatGPT !
*/

// for JSON storage upon shutdown:
use serde::{Serialize, Deserialize};
use std::fs;
use std::os::raw::c_int;
use std::ffi::CStr;
use std::os::raw::c_char;


// process_data.rs
use crate::ffi::{DartToRustElementFFI};



use crate::ffi::{constSelectedNumberListSize,
constSelectedNumStateListSize,
constSelectedPatternListSize,
constRequestedElementHighLightTypeSize,
constRequestedCandHighLightTypeSize};



#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct SerializableElement {
    row: u8,
    col: u8,
    selectedNum: u8,
    selectedNumStateList: Vec<u8>,
    selectedCandList: Vec<u8>,
    selectedPatternList: Vec<u8>,
    requestedElementHighLightType: Vec<u8>,
    requestedCandHighLightType: Vec<u8>,
}


#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct AppData {
    rows: u8,
    cols: u8,
    elements: Vec<SerializableElement>,
}



impl From<&DartToRustElementFFI> for SerializableElement {
    fn from(e: &DartToRustElementFFI) -> Self {
        SerializableElement {
            row: e.row,
            col: e.col,
            selectedNum: e.selectedNum,
            selectedNumStateList: e.selectedNumStateList.to_vec(),
            selectedCandList: e.selectedCandList.to_vec(),
            selectedPatternList: e.selectedPatternList.to_vec(),
            requestedElementHighLightType: e.requestedElementHighLightType.to_vec(),
            requestedCandHighLightType: e.requestedCandHighLightType.to_vec(),
        }
    }
}

impl From<&SerializableElement> for DartToRustElementFFI {
    fn from(e: &SerializableElement) -> Self {
        let mut s = DartToRustElementFFI {
            row: e.row,
            col: e.col,
            selectedNum: e.selectedNum,
            selectedNumStateList: [0; constSelectedNumStateListSize as usize],
            selectedCandList: [0; constSelectedNumberListSize as usize],
            selectedPatternList: [0; constSelectedPatternListSize as usize],
            requestedElementHighLightType: [0; constRequestedElementHighLightTypeSize as usize],
            requestedCandHighLightType: [0; constRequestedCandHighLightTypeSize as usize ],
        };
        s.selectedNumStateList[..e.selectedNumStateList.len().min(constSelectedNumStateListSize  as usize)]
            .copy_from_slice(&e.selectedNumStateList);
        s.selectedCandList[..e.selectedCandList.len().min(constSelectedNumberListSize  as usize)]
            .copy_from_slice(&e.selectedCandList);
        s.selectedPatternList[..e.selectedPatternList.len().min(constSelectedPatternListSize  as usize)]
            .copy_from_slice(&e.selectedPatternList);
        s.requestedElementHighLightType[..e.requestedElementHighLightType.len().min(constRequestedElementHighLightTypeSize  as usize)]
            .copy_from_slice(&e.requestedElementHighLightType);
        /* s.requestedCandHighLightType[..e.requestedCandHighLightType.len().min(constRequestedCandHighLightTypeSize  as usize)]
            .copy_from_slice(&e.requestedCandHighLightType); */

        s
    }
}

#[no_mangle]
pub unsafe extern "C" fn save_data(
    ptr: *const DartToRustElementFFI,
    rows: u8,
    cols: u8,
    path: *const c_char, // <- new argument
) -> c_int {
    if ptr.is_null() || path.is_null() {
        return -1;
    }

    // Convert C string to Rust &str
    let c_str = CStr::from_ptr(path);
    let path_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return -6, // invalid UTF-8
    };

    let slice = std::slice::from_raw_parts(ptr, (rows as usize) * (cols as usize));

    let data = AppData {
        rows,
        cols,
        elements: slice.iter().map(SerializableElement::from).collect(),
    };

    match serde_json::to_string(&data) {
        Ok(json) => match fs::write(path_str, json) {
            Ok(_) => 0,
            Err(_) => -2,
        },
        Err(_) => -3,
    }
}

#[no_mangle]
pub unsafe extern "C" fn load_data(
    ptr: *mut DartToRustElementFFI,
    rows: u8,
    cols: u8,
    path: *const c_char, // <- new argument
) -> c_int {
    if ptr.is_null() || path.is_null() {
        return -1;
    }

    let c_str = CStr::from_ptr(path);
    let path_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return -6, // invalid UTF-8
    };

    match fs::read_to_string(path_str) {
        Ok(json) => match serde_json::from_str::<AppData>(&json) {
            Ok(data) => {
                if data.rows != rows || data.cols != cols {
                    return -4;
                }

                let slice =
                    std::slice::from_raw_parts_mut(ptr, (rows as usize) * (cols as usize));

                if slice.len() != data.elements.len() {
                    return -5;
                }

                for (dst, src) in slice.iter_mut().zip(data.elements.iter()) {
                    *dst = DartToRustElementFFI::from(src);
                    print!("RUST : Loading JSON from file.");
                }

                0
            }
            Err(_) => -2,
        },
        Err(_) => -3,
    }
}




// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.