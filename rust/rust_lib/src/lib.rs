// Using FFI (Foreign Function Interface)
// Embed Rust code directly into Flutter using dart:ffi.
// Rust code compiled to a dynamic library (.so, .dll, .dylib).

/////////////////////////////////////
// constants
/////////////////////////////////////

// Hardcoded sizes of above types
pub const constSelectedNumberListSize: usize    = 9;
pub const constSelectedPatternListSize: usize   = 5;
pub const constSelectedNumberList: [u8; constSelectedNumberListSize] = [0, 0, 0, 0, 0, 0, 0, 0, 0];
pub const constSelectedPatternList: [u8; constSelectedPatternListSize] = [0, 0, 0, 0, 0];

use std::alloc::{alloc, dealloc, Layout};

#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct DartToRustElementFFI {
    pub row:                    u8,
    pub col:                    u8,
    pub selectedNumState:       u8,
    pub selectedCandState:      [u8; constSelectedNumberListSize]
    pub highLightCandRequest:   [u8; constSelectedNumberListSize]
    pub highLightTypeRequest:   [u8; constSelectedPatternListSize]
}

#[unsafe(no_mangle)]
pub extern "C" fn create_matrix(rows: u8, cols: u8) -> *mut DartToRustElementFFI {
    let count = (rows * cols) as usize;
    let layout = Layout::array::<DartToRustElementFFI>(count).unwrap();

    unsafe {
        let ptr = alloc(layout) as *mut DartToRustElementFFI;
        if ptr.is_null() {
            return std::ptr::null_mut();
        }

        for r in 0..rows {
            for c in 0..cols {
                let idx = (r * cols + c) as isize;
                let cell = ptr.offset(idx);
                (*cell).row = r;
                (*cell).col = c;
                (*cell).selectedNumState = 0;
                (*cell).selectedCandState = constSelectedNumberList; // all false
                (*cell).highLightCandRequest= constSelectedNumberList; // all false
                (*cell).highLightTypeRequest= constSelectedPatternList;// all false
            }
        }

        ptr // return value
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn update_matrix(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8)) {
    if ptr.is_null() {
        return;
    }
    let slice = unsafe { std::slice::from_raw_parts_mut(ptr, (rows * cols) as usize) };
    for cell in slice.iter_mut() {

        // temprary code
        cell.selectedNumState = 1;

    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_matrix(ptr: *mut DartToRustElementFFI, rows: u8, cols: u8) {
    if ptr.is_null() {
        return;
    }
    let count = (rows * cols) as usize;
    let layout = Layout::array::<DartToRustElementFFI>(count).unwrap();
    unsafe {
        dealloc(ptr as *mut u8, layout);
    }
}

