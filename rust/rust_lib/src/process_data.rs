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

// process_data.rs
use crate::ffi::{DartToRustElementFFI};

use crate::ffi::{CONST_MATRIX_ELEMENTS};

use crate::ffi::{PatternList};

#[no_mangle]
pub unsafe extern "C" fn check_all_elements(ptr: *mut DartToRustElementFFI, len: usize) {
    if ptr.is_null() {
        return;
    }

    for i in 0..len {
        let cell = &mut *ptr.add(i);
        check_cell_for_patterns(cell);
    }
}


#[no_mangle]
pub unsafe extern "C" fn check_one_element(ptr: *mut DartToRustElementFFI, idx: usize) {
    if ptr.is_null() {
        return;
    }

    assert!(idx < CONST_MATRIX_ELEMENTS as usize);

    let cell = &mut *ptr.add(idx);
    check_cell_for_patterns(cell);
}

unsafe fn check_cell_for_patterns(cell: &mut DartToRustElementFFI) {
    // Reset highlights first
    for hl in cell.requestedCandHighLightType.iter_mut() {
        *hl = 0;
    }

    if cell.selectedNum == 0 {
        let selected_count = cell
            .selectedCandList
            .iter()
            .filter(|&&x| x != 0)
            .count();

        if selected_count == 2 {
            for (cand, hl) in cell
                .selectedCandList
                .iter()
                .zip(cell.requestedCandHighLightType.iter_mut())
            {
                if *cand != 0 {
                    *hl = PatternList::PAIRS as u8;
                }
            }
        }
        else if selected_count == 1 {
            for (cand, hl) in cell
                .selectedCandList
                .iter()
                .zip(cell.requestedCandHighLightType.iter_mut())
            {
                if *cand != 0 {
                    *hl = PatternList::SINGLES as u8;
                }
            }

        }
    }
}


// Copyright 2025, Mirko THULKE, Versailles