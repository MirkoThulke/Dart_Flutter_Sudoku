// Using FFI (Foreign Function Interface)
// Embed Rust code directly into Flutter using dart:ffi.
// Rust code compiled to a dynamic library (.so, .dll, .dylib).


use flutter_rust_bridge::frb;

pub fn add(left: u64, right: u64) -> u64 {
    left + right
}