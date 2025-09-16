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

import 'shared_types.dart'; // RUST FFI backend Interface
import 'dart:ffi';

import 'package:logging/logging.dart';

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
// Debug Logging class
final Logger _logger = Logger('RustMatrixLogger');
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
/// @startuml
/// class Cell {
/// + int row
/// + int col
/// + int selectedNumState
/// + selectedCandState : bool[9]
/// + highLightCandRequest: bool[9]
/// + highLightTypeRequest: bool[constSelectedPatternListSize]
/// }
///
/// note right of Cell::row
///   row number
/// end note
/// note right of Cell::col
///   collumn number
/// end note
/// note right of Cell::selectedNumState
///   selected final number choice for this cell: [1...9]
///   [0] : no number set
/// end note
/// note right of Cell::selectedCandState
///   selected candidates for this cell
/// end note
/// note right of Cell::highLightCandRequest
///   request to highlight canidates depending on the highlighting patter which the user has chosen
/// end note
/// note right of Cell::highLightTypeRequest
///   requested highlighting-pattern which the user has chosen
/// end note
/// @enduml

/* Dart class to map Dart matrix data to the Rust structure
This mirrors your Rust struct.
Each Array<Bool> is native memory, so you cannot assign a Dart list directly.
Access individual elements with indexing: cell.selectedCandState[i]. */
final class DartToRustElementFFI extends Struct {
  @Uint8()
  external int row;

  @Uint8()
  external int col;

  @Uint8()
  external int selectedNumState;

  @Array(constSelectedNumberListSize)
  external Array<Uint8> selectedCandList;

  @Array(constSelectedPatternListSize)
  external Array<Uint8> selectedPatternList;

  @Array(constRequestedElementHighLightTypeListSize)
  external Array<Uint8> requestedElementHighLightType;

  @Array(constRequestedCandHighLightTypeListSize)
  external Array<Uint8> requestedCandHighLightType;
}

/* Dart class to map Dart matrix data to the Rust structure.
Dart “friendly” class.
This is a pure Dart copy of the Rust struct.
You use this when you want Dart-side representation of the Rust matrix.
Good for debugging or local processing. */

class DartToRustElement {
  final int row;
  final int col;

  // Final element number chosen
  int selectedNumState = 0; // no number set
  // Candidates which are chosen
  SelectedCandList selectedCandList = List.from(constSelectedCandList);
  // User pattern display request
  SelectedPatternList selectedPatternList = List.from(constSelectedPatternList);
  // Rust feedback on how to highlight the cell
  RequestedElementHighLightType requestedElementHighLightType =
      List.from(constRequestedElementHighLightType);
  // Rust feedback on how to highlight each candidate
  RequestedCandHighLightType requestedCandHighLightType =
      List.from(constRequestedCandHighLightType);

  // Constructure to define position of Cell inside matrix
  DartToRustElement(this.row, this.col);

  // for debugging
  @override
  String toString() {
    return 'DartToRustElement('
        'row=$row, '
        'col=$col, '
        'selectedNumState=$selectedNumState, '
        'selectedCandList=$selectedCandList, '
        'selectedPatternList=$selectedPatternList, '
        'requestedElementHighLightType=$requestedElementHighLightType'
        'requestedCandHighLightType=$requestedCandHighLightType'
        ')';
  }
}

//////////////////////////////////////////////////////
// Native bindings
//////////////////////////////////////////////////////
// Matches the exact C/Rust function signature

// Matches the exact C/Rust function signature
typedef CreateMatrixNative = Pointer<DartToRustElementFFI> Function(
    Uint8 rows, Uint8 cols);
// Dart-friendly version
typedef CreateMatrixDart = Pointer<DartToRustElementFFI> Function(
    int rows, int cols);

// Matches the exact C/Rust function signature
typedef UpdateMatrixNative = Void Function(
    Pointer<DartToRustElementFFI> ptr, Uint8 rows, Uint8 cols);
// Dart-friendly version
typedef UpdateMatrixDart = void Function(
    Pointer<DartToRustElementFFI> ptr, int rows, int cols);

// Matches the exact C/Rust function signature
typedef FreeMatrixNative = Void Function(
    Pointer<DartToRustElementFFI> ptr, Uint8 rows, Uint8 cols);
// Dart-friendly version
typedef FreeMatrixDart = void Function(
    Pointer<DartToRustElementFFI> ptr, int rows, int cols);

/*
Helper to store matrix metadata for Finalizer
RustMatrix class :
Wraps the FFI pointer into a Dart class.
Uses a Finalizer to automatically free Rust memory when Dart object is garbage collected.
update() → calls Rust’s update_matrix.
printMatrix() → reads values directly from Rust memory.
✅ Key design: you own the pointer on Dart side, and you must free it either via dispose() or let the Finalizer handle it.
*/

/*
This is a simple metadata container for the Rust matrix.
The Finalizer needs this to know which pointer to free when the Dart object is garbage collected.
You never use _MatrixHandle directly; it’s only for the Finalizer.
*/
class _MatrixHandle {
  final Pointer<DartToRustElementFFI> ptr;
  final int rows;
  final int cols;
  const _MatrixHandle(this.ptr, this.rows, this.cols);
}

/*
Allocate a Rust matrix
final rustMatrix = RustMatrix(dylib, rows, cols);
Calls create_matrix in Rust.
Stores the returned pointer (ptr) in Dart.
Automatically free memory
static final Finalizer<_MatrixHandle> _finalizer = Finalizer<_MatrixHandle>((handle) {
    _freeMatrix(handle.ptr, handle.rows, handle.cols);
});
When Dart GC collects the RustMatrix object, the Rust memory is automatically freed.
_MatrixHandle tells the finalizer what pointer to free.
Manual cleanup (optional)
rustMatrix.dispose();
Detaches the finalizer and calls free_matrix immediately.
Useful if you want deterministic memory release.
Call Rust update function
rustMatrix.update();
Calls your Rust update_matrix function to modify the matrix on the Rust side.
Debug / inspect matrix
rustMatrix.printMatrix();
Reads matrix values from Rust memory and prints them.
Useful for testing.
*/
class RustMatrix {
  final Pointer<DartToRustElementFFI> ptr;
  final int rows;
  final int cols;

  static late final UpdateMatrixDart _updateMatrix;
  static late final FreeMatrixDart _freeMatrix;

  // Finalizer to free Rust memory
  static final Finalizer<_MatrixHandle> _finalizer =
      Finalizer<_MatrixHandle>((handle) {
    _freeMatrix(handle.ptr, handle.rows, handle.cols);
  });

  RustMatrix._(this.ptr, this.rows, this.cols);

  /// Factory: creates Rust matrix from dynamic library
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

  // -------------------------------
  // Call Rust update function
  // -------------------------------
  void update() {
    _updateMatrix(ptr, rows, cols);
  }

  void writeCellToRust(Pointer<DartToRustElementFFI> ptr,
      List<List<DartToRustElement>> dartMatrix, int r, int c) {
    final idx = r * constSudokuNumCol + c;
    final cellPtr = ptr.elementAt(idx).ref;
    final dartCell = dartMatrix[r][c];

    // Copy scalar values
    cellPtr.row = dartCell.row;
    cellPtr.col = dartCell.col;
    cellPtr.selectedNumState = dartCell.selectedNumState;

    // Copy arrays element by element
    for (int i = 0; i < constSelectedCandListSize; i++) {
      // Check which number is selected (corresponding bit is TRUE)
      assert(i < constSelectedCandListSize, 'i  exceeds maximum allowed size!');

      cellPtr.selectedCandList[i] = boolToU8(dartCell.selectedCandList[i]);
      cellPtr.requestedCandHighLightType[i] =
          dartCell.requestedCandHighLightType[i];
    }
    for (int i = 0; i < constSelectedPatternListSize; i++) {
      assert(
          i < constSelectedPatternListSize, 'i  exceeds maximum allowed size!');

      cellPtr.selectedPatternList[i] =
          boolToU8(dartCell.selectedPatternList[i]);
      cellPtr.requestedElementHighLightType[i] =
          boolToU8(dartCell.requestedElementHighLightType[i]);
    }
  }

/*
Writing the complete Dart matrix to Rust
We can optimize writeMatrixToRust so it writes the entire Dart matrix into Rust memory efficiently, 
without calling writeCell repeatedly. Instead, we calculate the flat index once and copy arrays directly.
Why this is efficient:
No repeated writeCell calls — avoids function overhead for every cell.
Flat memory indexing: uses idx = r * cols + c once per cell.
Element-by-element copy for arrays: required for FFI safety, since Array<Bool> can’t be assigned directly.
Scales better for larger matrices while keeping all logic in one loop.
*/
  void writeMatrixToRust(
    Pointer<DartToRustElementFFI> ptr,
    List<List<DartToRustElement>> dartMatrix,
    int rows,
    int cols,
  ) {
    // Flatten the matrix for direct pointer indexing
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final idx = r * cols + c;
        final cellPtr = ptr.elementAt(idx).ref;
        final dartCell = dartMatrix[r][c];

        // Copy scalar values
        cellPtr.row = dartCell.row;
        cellPtr.col = dartCell.col;
        cellPtr.selectedNumState = dartCell.selectedNumState;

        // Copy arrays element by element
        for (int i = 0; i < constSelectedCandListSize; i++) {
          assert(i < constSelectedCandListSize,
              'i  exceeds maximum allowed size!');
          cellPtr.selectedCandList[i] =
              boolToU8(dartCell.selectedCandList[i]); // Rust requirs uint8
          cellPtr.requestedCandHighLightType[i] =
              dartCell.requestedCandHighLightType[i];
        }

        for (int i = 0; i < constSelectedPatternListSize; i++) {
          assert(i < constSelectedPatternListSize,
              'i  exceeds maximum allowed size!');
          cellPtr.selectedPatternList[i] =
              boolToU8(dartCell.selectedPatternList[i]); // Rust requirs uint8
          cellPtr.requestedElementHighLightType[i] = boolToU8(
              dartCell.requestedElementHighLightType[i]); // Rust requirs uint8
        }
      }
    }
  }

  // -------------------------------
  // Read a single cell from Rust into Dart
  // -------------------------------
  DartToRustElement readCellFromRust(int r, int c) {
    final cellPtr = ptr.elementAt(r * cols + c).ref;
    return DartToRustElement(cellPtr.row, cellPtr.col)
      ..selectedNumState = cellPtr.selectedNumState
      ..selectedCandList = List.generate(constSelectedCandListSize,
          (i) => u8ToBool(cellPtr.selectedCandList[i]))
      ..selectedPatternList = List.generate(constSelectedPatternListSize,
          (i) => u8ToBool(cellPtr.selectedPatternList[i]))
      ..requestedElementHighLightType = List.generate(
          constRequestedElementHighLightTypeListSize,
          (i) => u8ToBool(cellPtr.requestedElementHighLightType[i]))
      ..requestedCandHighLightType = List.generate(
          constRequestedCandHighLightTypeListSize,
          (i) => cellPtr.requestedCandHighLightType[i]);
  }

  // -------------------------------
  // Convert entire Rust matrix into Dart list
  // -------------------------------
  /* 
Reading the Rust matrix into Dart.
Convert Rust matrix → Dart list of lists.
Creates a 2D Dart list of DartToRustElement.
*/
// Reads the entire Rust matrix into Dart
  List<List<DartToRustElement>> readMatrixFromRust() {
    final result = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => DartToRustElement(0, 0),
        growable: false,
      ),
      growable: false,
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cellPtr = ptr.elementAt(r * cols + c).ref;
        result[r][c] = DartToRustElement(cellPtr.row, cellPtr.col)
          ..selectedNumState = cellPtr.selectedNumState
          ..selectedCandList = List.generate(constSelectedCandListSize,
              (i) => u8ToBool(cellPtr.selectedCandList[i]))
          ..selectedPatternList = List.generate(constSelectedPatternListSize,
              (i) => u8ToBool(cellPtr.selectedPatternList[i]))
          ..requestedElementHighLightType = List.generate(
              constRequestedElementHighLightTypeListSize,
              (i) => u8ToBool(cellPtr.requestedElementHighLightType[i]))
          ..requestedCandHighLightType = List.generate(
              constRequestedCandHighLightTypeListSize,
              (i) => cellPtr.requestedCandHighLightType[i]);
      }
    }

    return result;
  }

  // -------------------------------
  // Optional debug print
  // -------------------------------
  void printRustAllElements() {
    for (int r = 0; r < rows; r++) {
      String rowStr = '';
      for (int c = 0; c < cols; c++) {
        final cell = readCellFromRust(r, c); // returns DartToRustElement
        rowStr += '(${cell.row},${cell.col}=${cell.selectedNumState}) ';
      }
      _logger.fine(rowStr); // use 'fine' for debug-level messages
    }
  }

  // -------------------------------
  // Manual cleanup
  // -------------------------------
  void dispose() {
    _finalizer.detach(this);
    _freeMatrix(ptr, rows, cols);
  }
}
