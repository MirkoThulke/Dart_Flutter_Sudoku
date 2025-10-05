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
import 'package:flutter/widgets.dart';

import 'dart:io'; // to persist data on local storage

// FFI (Foreign Function Interface) to connect to RUST backend
import 'dart:ffi';

import 'package:path_provider/path_provider.dart';

import 'dart:async';

// Import specific dart files
import 'package:sudoku/utils/export.dart';

/// @startuml
/// class DataProvider {
/// - SelectedNumberList _selectedNumberList
/// - SelectedSetResetList _selectedSetResetList
/// - SelectedPatternList _selectedPatternList
/// - SelectedUndoIconList _selectedUndoIconList
/// - SelectAddRemoveList _selectAddRemoveList
/// + void updateDataNumberlist(SelectedNumberList selectedNumberListNewData)
/// + void updateDataselectedSetResetList(SelectedSetResetList selectedSetResetListNewData)
/// + void updateDataselectedPatternList(SelectedPatternList selectedPatternListNewData)
/// + void updateDataselectedUndoIconList(SelectedUndoIconList selectedUndoIconListNewData)
/// + void updateDataselectAddRemoveList(SelectAddRemoveList selectAddRemoveListNewData)
/// }
/// class ChangeNotifier <<mixin>> {
/// }
/// DataProvider ..|> ChangeNotifier
/// @enduml

// Use Provider Class is used to exchange data between widgets :
class DataProvider extends ChangeNotifier with WidgetsBindingObserver {
  // to handle app states
  DataStatus _status = DataStatus.loading;
  DataStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // HMI Input section :
  // HMI Number selection input
  SelectedNumberList _selectedNumberList =
      List<bool>.from(constSelectedNumberList);

  SelectedSetResetList _selectedSetResetList =
      List<bool>.from(constSelectedSetResetList);

  SelectedPatternList _selectedPatternList =
      List<bool>.from(constSelectedPatternList);

  SelectedUndoIconList _selectedUndoIconList =
      List<bool>.from(constSelectedUndoIconList);

  SelectedAddRemoveList _selectedAddRemoveList =
      List<bool>.from(constSelectedAddRemoveList);

  // Public getter
  SelectedNumberList get selectedNumberList => _selectedNumberList;
  SelectedSetResetList get selectedSetResetList => _selectedSetResetList;
  SelectedPatternList get selectedPatternList => _selectedPatternList;
  SelectedUndoIconList get selectedUndoIconList => _selectedUndoIconList;
  SelectedAddRemoveList get selectedAddRemoveList => _selectedAddRemoveList;

  void updateDataNumberlist(SelectedNumberList selectedNumberListNewData) {
    _selectedNumberList = selectedNumberListNewData;
    notifyListeners();
  }

  void updateDataselectedSetResetList(
      SelectedSetResetList selectedSetResetListNewData) {
    _selectedSetResetList = selectedSetResetListNewData;
    notifyListeners();
  }

  void updateDataselectedUndoIconList(
      SelectedUndoIconList selectedUndoIconListNewData) {
    _selectedUndoIconList = selectedUndoIconListNewData;
    notifyListeners();
  }

  /// Updated method
  Future<void> updateDataselectedRemoveList(
      SelectedAddRemoveList selectedAddRemoveListNewData) async {
    _selectedAddRemoveList = selectedAddRemoveListNewData;

    // Only do anything if the "erase" flag is set
    if (_selectedAddRemoveList[addRemoveListIndex.remove]) {
      // Optional: set a loading state to show spinner
      _status = DataStatus.loading;
      notifyListeners();

      // ✅ Now async/await works
      await callRustErase();
      await readMatrixFromRust();

      // Done — update status
      _status = DataStatus.ready;

      notifyListeners(); // signals UI rebuild if needed
    } else {
      notifyListeners(); // still notify for other buttons
    }
  }

  /// Updated method
  Future<void> updateDataselectedAddList(
      SelectedAddRemoveList selectedAddRemoveListNewData) async {
    _selectedAddRemoveList = selectedAddRemoveListNewData;

    // Only do anything if the "erase" flag is set
    if (_selectedAddRemoveList[addRemoveListIndex.add]) {
      // Optional: set a loading state to show spinner
      //  _status = DataStatus.loading;
      //  notifyListeners();

      writeFullMatrixToRust();
      callRustUpdate();
      readMatrixFromRust();
      /* After the Rust processing update */
      notifyListeners();

      // Done — update status
      _status = DataStatus.ready;

      notifyListeners(); // signals UI rebuild if needed
    } else {
      notifyListeners(); // still notify for other buttons
    }
  }

  void updateDataselectedPatternList(
      SelectedPatternList selectedPatternListNewData) {
    _selectedPatternList = selectedPatternListNewData;

    /* If the user presses the Pattern button, then the ChangeNotifier class
    is informed by calling this function.
    Then the matrix data is completely written into via the FFI interface into the 
    RUST matrix.
    */
    writeFullMatrixToRust();
    callRustUpdate();
    readMatrixFromRust();
    /* After the Rust processing update */
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////////////////
  // RUST FFI Backend Interface :
  // Backend section. Store matrix state  in backend.
  // only data is stored. The visual highlighting state is not stored in the backend

  late RustMatrix rustMatrix;
  late List<List<DartToRustElement>> dartMatrix;

  // RUST export path and filename to JSON file for data persistance
  late String appJsonPath; // late because we’ll initialize it asynchronously

  DataProvider() {
    // Register as observer to app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // link the Rust library
    // create the Rust matrix
    // and create a Dart SnapShot .

    // Start async initialization (non-blocking)
    _initAsync();
  }

/*
_initAsync() is async, called from the constructor without await.
Constructor returns immediately.
Async initialization continues in the background.
Any UI or consumer of DataProvider should handle loading state until notifyListeners() fires.
Avoid putting await directly in the constructor.
*/

  Future<void> _initAsync() async {
    try {
      final dylib = Platform.isAndroid
          ? DynamicLibrary.open('librust_backend.so')
          : Platform.isWindows
              ? DynamicLibrary.open('rust_backend.dll')
              : Platform.isMacOS
                  ? DynamicLibrary.open('librust_backend.dylib')
                  : DynamicLibrary.open('librust_backend.so');

      rustMatrix = RustMatrix(dylib, constSudokuNumRow, constSudokuNumCol);

      final bool jsonExists = await initJsonFile();

      if (jsonExists) {
        final loaded = await rustMatrix.loadFromJSON(appJsonPath);
        print('Rust loadFromJSON returned: $loaded');
        if (loaded) {
          dartMatrix = rustMatrix.readMatrixFromRust(
              rustMatrix.numRows, rustMatrix.numCols);

          final numRows = dartMatrix.length;
          final numCols = dartMatrix.isNotEmpty ? dartMatrix[0].length : 0;
          print('Number of rows: $numRows');
          if (dartMatrix.isNotEmpty) {
            final numCols = dartMatrix[0].length;
            print('Number of columns: $numCols');
          }
        } else {
          print('Rust JSON load failed');
        }
      }

      _status = DataStatus.ready;
      notifyListeners();
    } catch (e, st) {
      _status = DataStatus.error;
      _errorMessage = e.toString();
      print('DataProvider initialization failed: $e\n$st');
      notifyListeners();
    }
  }

  Future<bool> initJsonFile() async {
    final dir = await getApplicationDocumentsDirectory();

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    appJsonPath = '${dir.path}/sudoku_data.json';
    final file = File(appJsonPath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{}');
      return false;
    }

    return true;
  }

  // -------------------------------
  // App Lifecycle Handling
  // -------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // persist before app may be killed
      rustMatrix.saveToJSON(appJsonPath);
    }
  }

  RequestedCandHighLightType _requestedCandHighLightType =
      List<int>.from(constRequestedCandHighLightType);

  // Public getter
  RequestedCandHighLightType get requestedCandHighLightType =>
      _requestedCandHighLightType;

  void updateRequestedCandHighLightType(
      RequestedCandHighLightType requestedCandHighLightTypeNewData) {
    _requestedCandHighLightType = requestedCandHighLightTypeNewData;
    notifyListeners();
  }

  RequestedElementHighLightType _requestedElementHighLightType =
      List<bool>.from(constRequestedElementHighLightType);

  void updateRequestedElementHighLightType(
      RequestedElementHighLightType requestedElementHighLightTypeNewData) {
    _requestedElementHighLightType = requestedElementHighLightTypeNewData;
    notifyListeners();
  }

  // -------------------------------
  // Single-Cell Dart → Rust update
  // -------------------------------
  void writeCellToRust(int r, int c, int numRows, int numCols) {
    // Write into FFI interface class
    rustMatrix.writeCellToRust(
        rustMatrix.ptr, dartMatrix, r, c, numRows, numCols);
  }

  // -------------------------------
  // Full Dart → Rust sync
  // -------------------------------
  void writeFullMatrixToRust() {
    // Write into FFI interface class
    rustMatrix.writeMatrixToRust(
        rustMatrix.ptr, dartMatrix, rustMatrix.numRows, rustMatrix.numCols);
  }

  // -------------------------------
  // Single-cell Rust → Dart update
  // -------------------------------
  void readCellFromRust(int r, int c, int numRows, int numCols) {
    dartMatrix[r][c] = rustMatrix.readCellFromRust(r, c, numRows, numCols);
  }

  // -------------------------------
  // Read candidate pattern highlighting type from RUST
  // -------------------------------
  int readRequestedCandHighLightTypeFromRust(
      int r, int c, int cand, int numRows, int numCols) {
    if (cand >= 1 && cand <= 9) {
      dartMatrix[r][c] = rustMatrix.readCellFromRust(r, c, numRows, numCols);

      assert(cand <= constSelectedCandListSize,
          'cand exceeds maximum allowed size!');
      assert(cand > 0, 'cand < 1!');

      int _patternRequest_int = constIntPatternList.DEFAULT.value;

      _patternRequest_int =
          dartMatrix[r][c].requestedCandHighLightType[cand - 1];

      assert(
          _patternRequest_int <= constIntPatternList.user.value ||
              _patternRequest_int == constIntPatternList.DEFAULT.value,
          '_patternRequest_int exceeds maximum allowed size!');

      return _patternRequest_int;
    } else {
      throw RangeError('cand must be between 1 and 9, got $cand');
    }
  }

  // -------------------------------
  // Full Rust → Dart update
  // -------------------------------
  Future<void> readMatrixFromRust() async {
    // Update full snapshot from Rust
    dartMatrix =
        rustMatrix.readMatrixFromRust(rustMatrix.numRows, rustMatrix.numCols);
  }

  // -------------------------------
  // Call Rust update function
  // -------------------------------
  void callRustUpdate() {
    rustMatrix.update();
  }

  // -------------------------------
  // Call Rust erase function
  // -------------------------------
  Future<void> callRustErase() async {
    rustMatrix.erase();
  }

  // -------------------------------
  // Call Rust Cell update function
  // -------------------------------
  void callRustCellUpdate(int r, int c, int numRows, int numCols) {
    rustMatrix.updateCell(r, c, numRows, numCols);
  }

  // -------------------------------
  // Dispose / cleanup
  // -------------------------------
  @override
  // is automatically called by ChangeNotifierProvider
  void dispose() {
    // 1. Save Rust data to JSON
    rustMatrix.saveToJSON(appJsonPath); // call your Rust FFI save function

    // 2. Free Rust memory
    rustMatrix.dispose(); // FFI memory cleanup

    // Remove observer to avoid leaks
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // -------------------------------
  // Debug print
  // -------------------------------
  void printDebug() {
    rustMatrix.printRustAllElements();
  }
}

// Copyright 2025, Mirko THULKE, Versailles
