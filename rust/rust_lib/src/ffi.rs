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


// Using FFI (Foreign Function Interface)
// Embed Rust code directly into Flutter using dart:ffi.
// Rust code compiled to a dynamic library (.so, .dll, .dylib).

/* 
compile : in C:\...\appfolder\rust\rust_lib>
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ../android/app/src/main/jniLibs build --release


link to app : 
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ..\..\android\app\src\main\jniLibs build --release
*/

/* 
FFI function parameters are u8 (Dart-compatible).
Internal Rust indexing uses usize (casting from u8).
Array lengths also cast from u8 → usize.
Struct fields remain u8 so Dart @Uint8() works.
All unsafe operations are wrapped.

Rust uses u8 for struct fields (Dart-friendly).
Array lengths and indices are safely cast to usize internally.
Allocations, updates, and deallocation all compile cleanly.
*/

// for general tasks like FFI interface
use std::alloc::{alloc, dealloc, Layout};

use crate::process_data::check_one_element;
use crate::process_data::check_all_elements;

pub const MAX_UINT: u8 = 255;
pub const CONST_MATRIX_SIZE: u8 = 9;

pub const CONST_MATRIX_ELEMENTS: u8 = 81;

pub struct PatternList;

impl PatternList {
    pub const HI_LIGHT_ON: u8 = 0;
    pub const PAIRS: u8 = 1;
    pub const SINGLES: u8 = 2;
    pub const GIVENS: u8 = 3;

}

pub struct NumStateListIndex;

impl NumStateListIndex {
    pub const GIVENS: u8 = 0;
    pub const FUTUREUSE: u8 = 1;
}

// Sizes as u8 for FFI
pub const constSelectedNumberListSize: u8 = CONST_MATRIX_SIZE;
pub const constSelectedNumStateListSize: u8 = 2;
pub const constSelectedPatternListSize: u8 = 4;
pub const constRequestedElementHighLightTypeSize: u8 = 5;
pub const constRequestedCandHighLightTypeSize: u8 = CONST_MATRIX_SIZE;

// Special constant
pub const constPatternListOff: u8 = MAX_UINT;

// Arrays as u8, cast length to usize for Rust
pub const constSelectedNumberList: [u8; constSelectedNumberListSize as usize] =
    [0; constSelectedNumberListSize as usize];
pub const constSelectedNumStateList: [u8; constSelectedNumStateListSize as usize] =
    [0; constSelectedNumStateListSize as usize];
pub const constSelectedPatternList: [u8; constSelectedPatternListSize as usize] =
    [0; constSelectedPatternListSize as usize];
pub const constRequestedElementHighLightType: [u8; constRequestedElementHighLightTypeSize as usize] =
    [0; constRequestedElementHighLightTypeSize as usize];
pub const constRequestedCandHighLightType: [u8; constRequestedCandHighLightTypeSize as usize] =
    [constPatternListOff; constRequestedCandHighLightTypeSize as usize];

// All selected numbers
pub const constSelectedNumberListAllSelected: [u8; constSelectedNumberListSize as usize] =
    [1; constSelectedNumberListSize as usize];

#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct DartToRustElementFFI {
    pub row: u8,
    pub col: u8,
    pub selectedNum: u8,
    pub selectedNumStateList: [u8; constSelectedNumStateListSize as usize],
    pub selectedCandList: [u8; constSelectedNumberListSize as usize],
    pub selectedPatternList: [u8; constSelectedPatternListSize as usize],
    pub requestedElementHighLightType: [u8; constRequestedElementHighLightTypeSize as usize],
    pub requestedCandHighLightType: [u8; constRequestedCandHighLightTypeSize as usize],
}

#[no_mangle]
pub unsafe extern "C" fn create_matrix(rows: u8, cols: u8) -> *mut DartToRustElementFFI {
    let rows_usize = rows as usize;
    let cols_usize = cols as usize;

    assert!(rows == constSelectedNumberListSize);
    assert!(cols == constSelectedNumberListSize);

    let count = rows_usize * cols_usize;
    let layout = Layout::array::<DartToRustElementFFI>(count).unwrap();
    let ptr = alloc(layout) as *mut DartToRustElementFFI;

    if ptr.is_null() {
        return std::ptr::null_mut();
    }

    for r in 0..rows_usize {
        for c in 0..cols_usize {
            let idx = r * cols_usize + c;
            let cell = ptr.add(idx);

            // Unsafe block to write raw pointer data
            unsafe {
                (*cell).row = r as u8;
                (*cell).col = c as u8;
                (*cell).selectedNum = 0;
                (*cell).selectedNumStateList = constSelectedNumStateList;
                (*cell).selectedCandList = constSelectedNumberList;
                (*cell).selectedPatternList = constSelectedPatternList;
                (*cell).requestedElementHighLightType = constRequestedElementHighLightType;
                (*cell).requestedCandHighLightType = constRequestedCandHighLightType;
            }
        }
    }

    ptr
}

#[no_mangle]
pub unsafe extern "C" fn update_cell(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8, idx: u8) {
    if ptr.is_null() {
        return;
    }

    let rows_usize = rows as usize;
    let cols_usize = cols as usize;
    let count = rows_usize * cols_usize;

    // Check matrix size
    assert!(count <= CONST_MATRIX_ELEMENTS as usize);

    // check max. index
    assert!((idx as usize) < count);

    // Check if the element has only 2 candidates
    check_one_element(ptr, idx as usize)

}

#[no_mangle]
pub unsafe extern "C" fn erase_matrix(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8, erase_givens: u8) {
    if ptr.is_null() {
        return;
    }

    let rows_usize = rows as usize;
    let cols_usize = cols as usize;
    let count = rows_usize * cols_usize;

    // Check matrix size
    assert!(count <= CONST_MATRIX_ELEMENTS as usize);

    for r in 0..rows_usize {
        for c in 0..cols_usize {
            let idx = r * cols_usize + c;
            
            // check max. index
            assert!(idx < count);

            let cell = &mut *ptr.add(idx);
            
            // Unsafe block to write raw pointer data
            unsafe {
                if erase_givens > 0  {
                    // erase givens
                    (*cell).selectedNum = 0;
                    (*cell).selectedNumStateList = constSelectedNumStateList;
                    (*cell).selectedCandList = constSelectedNumberList;
                    (*cell).selectedPatternList = constSelectedPatternList;
                    (*cell).requestedElementHighLightType = constRequestedElementHighLightType;
                    (*cell).requestedCandHighLightType = constRequestedCandHighLightType;
                }
                else if erase_givens == 0{
                    // do not erase givens
                    if (*cell).selectedNumStateList[NumStateListIndex::GIVENS as usize] == 0 {
                        // Not a given, erase
                        (*cell).selectedNum = 0;
                        (*cell).selectedNumStateList = constSelectedNumStateList;
                        
                    }

                    // Always erase candidates and highlights
                    (*cell).selectedCandList = constSelectedNumberList;
                    (*cell).selectedPatternList = constSelectedPatternList;
                    (*cell).requestedElementHighLightType = constRequestedElementHighLightType;
                    (*cell).requestedCandHighLightType = constRequestedCandHighLightType;

                }
                else {
                    // do nothing
                }
            }
        }
    }

}


#[no_mangle]
pub unsafe extern "C" fn set_all_candidates(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8) {
    if ptr.is_null() {
        return;
    }

    let rows_usize = rows as usize;
    let cols_usize = cols as usize;
    let count = rows_usize * cols_usize;

    // Check matrix size
    assert!(count <= CONST_MATRIX_ELEMENTS as usize);

    for r in 0..rows_usize {
        for c in 0..cols_usize {
            let idx = r * cols_usize + c;
            
            // check max. index
            assert!(idx < count);

            let cell = &mut *ptr.add(idx);


            
            // Unsafe block to write raw pointer data
            unsafe {
                // only if no number is selected
                if (*cell).selectedNum == 0 {

                    // Set all candidates
                    (*cell).selectedCandList = constSelectedNumberListAllSelected;
                    
                }
                else {
                    // do nothing
                }
            }
        }
    }

}

#[no_mangle]
pub unsafe extern "C" fn update_matrix(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8) {
    if ptr.is_null() {
        return;
    }

    let rows_usize = rows as usize;
    let cols_usize = cols as usize;
    let count = rows_usize * cols_usize;

    // Check matrix size
    assert!(count <= CONST_MATRIX_ELEMENTS as usize);

    // ✅ Just do all elements at once
    check_all_elements(ptr, count);

}



// Add update cell function

#[no_mangle]
pub unsafe extern "C" fn free_matrix(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8) {
    if ptr.is_null() {
        return;
    }

    let rows_usize = rows as usize;
    let cols_usize = cols as usize;
    let count = rows_usize * cols_usize;
    let layout = Layout::array::<DartToRustElementFFI>(count).unwrap();

    unsafe { dealloc(ptr as *mut u8, layout) };
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.