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

import 'dart:ffi';

///////////////////////////////////////////////////////////////////
/* FFI (Foreign Function Interface) to connect to the RUST backend
  Compiles RUST *.so libraries must be placed in respective folder
  example : 
  android/app/src/main/jniLibs/arm64-v8a/librust_backend.so
  android/app/src/main/jniLibs/armeabi-v7a/librust_backend.so
        
  Usage : 
        provider.updateCell(1, 2, 42.0); // update a cell
        provider.callRustUpdate(); // call Rust update

        final lengthData = provider.snapshot.length;
        final rowData = provider.snapshot[row];

        // Take snapshot into Dart List<List<CellData>>
        var snapshot = toDartList(matrix.ptr, matrix.rows, matrix.cols);
*/

////////////////////////////////////////////////////////////
/// @startuml
/// class Cell {
/// - external int row;
/// - external int col;
///
///
///
/// }
/// @enduml
// Rust struct mapping
sealed class Cell extends Struct {
  @Int32()
  external int row;

  @Int32()
  external int col;

  @Float()
  external double value;
}

// For Dart
class CellData {
  final int row;
  final int col;
  final double value;

  const CellData(this.row, this.col, this.value);

  @override
  String toString() => "($row,$col=$value)";
}

// Native bindings
typedef CreateMatrixNative = Pointer<Cell> Function(Int32, Int32);
typedef CreateMatrixDart = Pointer<Cell> Function(int, int);

typedef UpdateMatrixNative = Void Function(Pointer<Cell>, Int32, Int32);
typedef UpdateMatrixDart = void Function(Pointer<Cell>, int, int);

typedef FreeMatrixNative = Void Function(Pointer<Cell>, Int32, Int32);
typedef FreeMatrixDart = void Function(Pointer<Cell>, int, int);

// Convert Rust matrix → Dart list of lists
List<List<CellData>> toDartList(Pointer<Cell> ptr, int rows, int cols) {
  final result = List.generate(
      rows,
      (r) => List<CellData>.filled(cols, const CellData(0, 0, 0.0),
          growable: false));

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final idx = r * cols + c;
      final cell = ptr.elementAt(idx).ref;
      result[r][c] = CellData(cell.row, cell.col, cell.value);
    }
  }

  return result;
}

void writeCell(
    Pointer<Cell> ptr, int rows, int cols, int r, int c, double newValue) {
  final idx = r * cols + c;
  ptr.elementAt(idx).ref.value = newValue;
}

// Helper to store matrix metadata for Finalizer
class _MatrixHandle {
  final Pointer<Cell> ptr;
  final int rows;
  final int cols;
  const _MatrixHandle(this.ptr, this.rows, this.cols);
}

class RustMatrix {
  final Pointer<Cell> ptr;
  final int rows;
  final int cols;

  static late final UpdateMatrixDart _updateMatrix;
  static late final FreeMatrixDart _freeMatrix;

  // Finalizer to free matrix when GC collects RustMatrix
  static final Finalizer<_MatrixHandle> _finalizer =
      Finalizer<_MatrixHandle>((handle) {
    _freeMatrix(handle.ptr, handle.rows, handle.cols);
  });

  RustMatrix._(this.ptr, this.rows, this.cols);

  factory RustMatrix(DynamicLibrary dylib, int rows, int cols) {
    final createMatrix = dylib
        .lookupFunction<CreateMatrixNative, CreateMatrixDart>('create_matrix');
    _updateMatrix = dylib
        .lookupFunction<UpdateMatrixNative, UpdateMatrixDart>('update_matrix');
    _freeMatrix =
        dylib.lookupFunction<FreeMatrixNative, FreeMatrixDart>('free_matrix');

    final ptr = createMatrix(rows, cols);
    if (ptr.address == 0) {
      throw Exception("Rust failed to allocate matrix!");
    }

    final matrix = RustMatrix._(ptr, rows, cols);
    _finalizer.attach(matrix, _MatrixHandle(ptr, rows, cols), detach: matrix);
    return matrix;
  }

  void update() {
    _updateMatrix(ptr, rows, cols);
  }

  void printMatrix() {
    for (int r = 0; r < rows; r++) {
      String rowStr = "";
      for (int c = 0; c < cols; c++) {
        final idx = r * cols + c;
        final cell = ptr.elementAt(idx).ref;
        rowStr += "(${cell.row},${cell.col}=${cell.value.toStringAsFixed(1)}) ";
      }
      print(rowStr);
    }
  }

  // Optional manual cleanup
  void dispose() {
    _finalizer.detach(this);
    _freeMatrix(ptr, rows, cols);
  }
}
