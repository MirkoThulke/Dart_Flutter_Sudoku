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

  SelectAddRemoveList _selectAddRemoveList =
      List<bool>.from(constSelectAddRemoveList);

  // Public getter
  SelectedNumberList get selectedNumberList => _selectedNumberList;
  SelectedSetResetList get selectedSetResetList => _selectedSetResetList;
  SelectedPatternList get selectedPatternList => _selectedPatternList;
  SelectedUndoIconList get selectedUndoIconList => _selectedUndoIconList;
  SelectAddRemoveList get selectAddRemoveList => _selectAddRemoveList;

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

  void updateDataselectAddRemoveList(
      SelectAddRemoveList selectAddRemoveListNewData) {
    _selectAddRemoveList = selectAddRemoveListNewData;
    notifyListeners();
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

  // Track whether initialization is complete
  bool _initialized = false;
  bool get initialized => _initialized;

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

  final Completer<void> _initCompleter = Completer<void>();

  Future<void> _initAsync() async {
    // Check if JSON file exists, if not create it
    Future<bool> boolJSONfilePresent = false as Future<bool>;

    // Wait until the JSON file is ready
    try {
      boolJSONfilePresent = (await initJsonFile()) as Future<bool>;
    } catch (e, st) {
      print('DataProvider initialization failed: $e\n$st');
      _initialized = false;
      _initCompleter.completeError(e);
    }

    // Load Rust library & create matrix
    final dylib = Platform.isAndroid
        ? DynamicLibrary.open('librust_backend.so')
        : Platform.isWindows
            ? DynamicLibrary.open('rust_backend.dll')
            : Platform.isMacOS
                ? DynamicLibrary.open('librust_backend.dylib')
                : DynamicLibrary.open('librust_backend.so');

    rustMatrix = RustMatrix(dylib, constSudokuNumRow, constSudokuNumCol);

    // Read local persisted data
    if (await boolJSONfilePresent) {
      if (await rustMatrix.loadFromJSON(appJsonPath)) {
        // JSON file exists and loaded successfully
        // Create Dart snapshot
        dartMatrix = rustMatrix.readMatrixFromRust(
            rustMatrix.numRows, rustMatrix.numCols);
      }
    } else {
      // JSON file does not exist or failed to load, initialize with default values
      // Keep dedault values
    }

    // Mark initialization complete
    _initialized = true;

    // Notify listeners that data is ready
    notifyListeners();

    _initCompleter.complete(); // signal that initialization is done
  }

  Future<void> get initializationDone => _initCompleter.future;

  Future<bool> initJsonFile() async {
    // Check if JSON file exists, if not create it
    Future<bool> _boolJSONfilePresent = false as Future<bool>;

    final dir = await getApplicationDocumentsDirectory();

    // Ensure the directory exists
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    appJsonPath = '${dir.path}/sudoku_data.json';

    final file = File(appJsonPath);

    // Ensure file exists
    if (!await file.exists()) {
      // JSON file does not exist
      await file.create(recursive: true);
      await file.writeAsString('{}');
    } else {
      // JSON file already exists
      _boolJSONfilePresent = true as Future<bool>;
    }

    return _boolJSONfilePresent;
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
  void readMatrixFromRust() {
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
