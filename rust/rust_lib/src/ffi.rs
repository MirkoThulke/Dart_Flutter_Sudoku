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


// Using FFI (Foreign Function Interface)
// Embed Rust code directly into Flutter using dart:ffi.
// Rust code compiled to a dynamic library (.so, .dll, .dylib).

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

use crate::process_data::check_for_element_pair;
use crate::process_data::check_for_all_pairs;

pub const MAX_UINT: u8 = 255;
pub const CONST_MATRIX_SIZE: u8 = 9;

pub const CONST_MATRIX_ELEMENTS: u8 = 81;

pub struct PatternList;

impl PatternList {
    pub const HI_LIGHT_ON: u8 = 0;
    pub const PAIRS: u8 = 1;
    pub const MATCH_PAIRS: u8 = 2;
    pub const TWINS: u8 = 3;
    pub const USER: u8 = 4;
}



// Sizes as u8 for FFI
pub const constSelectedNumberListSize: u8 = CONST_MATRIX_SIZE;
pub const constSelectedPatternListSize: u8 = 5;
pub const constRequestedElementHighLightTypeSize: u8 = 5;
pub const constRequestedCandHighLightTypeSize: u8 = CONST_MATRIX_SIZE;

// Special constant
pub const constPatternListOff: u8 = MAX_UINT;

// Arrays as u8, cast length to usize for Rust
pub const constSelectedNumberList: [u8; constSelectedNumberListSize as usize] =
    [0; constSelectedNumberListSize as usize];
pub const constSelectedPatternList: [u8; constSelectedPatternListSize as usize] =
    [0; constSelectedPatternListSize as usize];
pub const constRequestedElementHighLightType: [u8; constRequestedElementHighLightTypeSize as usize] =
    [0; constRequestedElementHighLightTypeSize as usize];
pub const constRequestedCandHighLightType: [u8; constRequestedCandHighLightTypeSize as usize] =
    [constPatternListOff; constRequestedCandHighLightTypeSize as usize];

#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct DartToRustElementFFI {
    pub row: u8,
    pub col: u8,
    pub selectedNumState: u8,
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
                (*cell).selectedNumState = 0;
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
    check_for_element_pair(ptr, idx as usize)



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

    for r in 0..rows_usize {
        for c in 0..cols_usize {
            let idx = r * cols_usize + c;

            // check max. index
            assert!(idx < count);

            // Check if the element has only 2 candidates
            check_for_all_pairs(ptr, idx)
        }
    }
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


// Copyright 2025, Mirko THULKE, Versailles