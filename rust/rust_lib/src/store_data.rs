/*
# -----------------------------------------------------------------------------
# Author: MIRKO THULKE 
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.
#
# Date: 2025, VERSAILLES, FRANCE
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING
# FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
# -----------------------------------------------------------------------------
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
constSelectedPatternListSize,
constRequestedElementHighLightTypeSize,
constRequestedCandHighLightTypeSize};



#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct SerializableElement {
    row: u8,
    col: u8,
    selectedNumState: u8,
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
            selectedNumState: e.selectedNumState,
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
            selectedNumState: e.selectedNumState,
            selectedCandList: [0; constSelectedNumberListSize as usize],
            selectedPatternList: [0; constSelectedPatternListSize as usize],
            requestedElementHighLightType: [0; constRequestedElementHighLightTypeSize as usize],
            requestedCandHighLightType: [0; constRequestedCandHighLightTypeSize as usize ],
        };

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




// Copyright 2025, Mirko THULKE, Versailles