// Using FFI (Foreign Function Interface)
// Embed Rust code directly into Flutter using dart:ffi.
// Rust code compiled to a dynamic library (.so, .dll, .dylib).

use std::alloc::{alloc, dealloc, Layout};

#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct Cell {
    pub row: i32,
    pub col: i32,
    pub value: f32,
}

#[unsafe(no_mangle)]
pub extern "C" fn create_matrix(rows: i32, cols: i32) -> *mut Cell {
    let count = (rows * cols) as usize;
    let layout = Layout::array::<Cell>(count).unwrap();

    unsafe {
        let ptr = alloc(layout) as *mut Cell;
        if ptr.is_null() {
            return std::ptr::null_mut();
        }

        for r in 0..rows {
            for c in 0..cols {
                let idx = (r * cols + c) as isize;
                let cell = ptr.offset(idx);
                (*cell).row = r;
                (*cell).col = c;
                (*cell).value = 0.0;
            }
        }

        ptr
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn update_matrix(ptr: *mut Cell, rows: i32, cols: i32) {
    if ptr.is_null() {
        return;
    }
    let slice = unsafe { std::slice::from_raw_parts_mut(ptr, (rows * cols) as usize) };
    for cell in slice.iter_mut() {
        cell.value += 1.0;
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_matrix(ptr: *mut Cell, rows: i32, cols: i32) {
    if ptr.is_null() {
        return;
    }
    let count = (rows * cols) as usize;
    let layout = Layout::array::<Cell>(count).unwrap();
    unsafe {
        dealloc(ptr as *mut u8, layout);
    }
}

