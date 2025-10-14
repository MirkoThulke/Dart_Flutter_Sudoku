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


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.