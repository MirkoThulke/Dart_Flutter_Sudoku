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

// Sizes as u8 for FFI
pub const constSelectedNumberListSize: u8 = 9;
pub const constSelectedPatternListSize: u8 = 5;
pub const constRequestedElementHighLightTypeSize: u8 = 5;
pub const constRequestedCandHighLightTypeSize: u8 = 9;

// Special constant
pub const constPatternListOff: u8 = 255;

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

    for r in 0..rows_usize {
        for c in 0..cols_usize {
            let idx = r * cols_usize + c;
            assert!(idx < count);

            // Example mutation (optional):
            // unsafe { (*ptr.add(idx)).selectedNumState = 1; }
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
