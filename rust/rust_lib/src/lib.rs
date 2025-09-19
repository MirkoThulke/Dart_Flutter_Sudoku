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

use std::alloc::{alloc, dealloc, Layout};
use serde::{Serialize, Deserialize};
use std::fs;

pub const MAX_UINT: u8 = 255;
pub const CONST_MATRIX_SIZE: u8 = 9;

pub const CONST_MATRIX_ELEMENTS: u8 = 81;

struct PatternList;

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
            checkForElementPair(ptr, idx)
        }
    }
}

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



// Check if element has exactly two candidates seletected
#[no_mangle]
pub unsafe extern "C" fn checkForElementPair(ptr: *mut DartToRustElementFFI, idx: usize) {
    if ptr.is_null() {
        return;
    }

    assert!(idx < CONST_MATRIX_ELEMENTS as usize);

    let elem = &mut *ptr.add(idx);

    if elem.selectedNumState == 0 {
        if elem.selectedCandList.iter().copied().sum::<u8>() == 2 {
            for (cand, hl) in elem
                .selectedCandList
                .iter()
                .zip(elem.requestedCandHighLightType.iter_mut())
            {
                if *cand != 0 {
                    *hl = PatternList::PAIRS as u8;
                }
            }
        }
    }    

}


/* Serialize Matrix data upon App shutdown. Deserialize upon App start. use JSON to store data.*/
#[derive(Serialize, Deserialize)]
struct AppData {
    counter: i32,
    name: String,
}

fn save_data(data: &AppData) -> std::io::Result<()> {
    let json = serde_json::to_string(data).unwrap();
    fs::write("app_data.json", json)
}

fn load_data() -> std::io::Result<AppData> {
    let json = fs::read_to_string("app_data.json")?;
    let data: AppData = serde_json::from_str(&json).unwrap();
    Ok(data)
}
