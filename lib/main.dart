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

import 'rust_matrix.dart'; // RUST FFI backend Interface
import 'shared_types.dart'; // RUST FFI backend Interface
import 'dart:math'; // basics
import 'package:flutter/material.dart'; // basics
import 'package:provider/provider.dart'; // data excahnge between classes
import 'package:logging/logging.dart'; // logging
import 'dart:io'; // to persist data on local storage

// FFI (Foreign Function Interface) to connect to RUST backend
import 'dart:ffi';

////// JAVA 1.19 used

/*
Important Flutter commands:

cmd> flutter run --profile --verbose // extended debug mode
command paletet> Open DevTools  // open the devtools browser
cmd> flutter upgrade
cmd> flutter pub upgrade 
cmd> flutter pub outdated
cmd> flutter build apk
cmd> flutter build apk --debug
cmd> flutter pub get
cmd> flutter clean
cmd> flutter analyse 
cmd> flutter clean build --refresh-dependencis
cmd> gradlew clean
cmd> gradlew cleanBuildCache
cmd> gradlew build
cmd> gradlew build --refresh-dependencies
cmd> flutter pub add "Dart package name"
cmd> flutter devices
cmd> flutter emulators
*/

////////////////////////////////////////////////////////////
// Debug Logging class
final log = Logger('SudokuLogger');
////////////////////////////////////////////////////////////

/////////////////////////////////////
// Use this class to handle the overall dimension of the app content depending on the actual screen size

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  static double? safeBlockAppBarGridVertical;
  static double? safeBlockSudokuGridVertical;
  static double? safeBlockHMIGridVertical;

  static double? safeBlockAppBarGridHorizontal;
  static double? safeBlockSudokuGridHorizontal;
  static double? safeBlockHMIGridHorizontal;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth!;
    blockSizeVertical = screenHeight!;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!);
    safeBlockVertical = (screenHeight! - _safeAreaVertical!);

// App screen space repartition in pixel :

// 5 percent height for AppBar, but not smaller than 20 logical pixel but smaller than aprox. 1 cm .
    safeBlockAppBarGridVertical = max(min(safeBlockVertical! * 0.05, 20.0), 40);

// Sudokugrid shall extend to the minimum of screen width / height,
// but not greater than 0.66 of this dimension; to leave enough space for the HMI segment.
// Height not smaller than aprox. 2cm

    if (safeBlockVertical! > safeBlockHorizontal!) {
      safeBlockSudokuGridVertical =
          min(safeBlockHorizontal!, safeBlockVertical! * 0.75);
    } else {
      safeBlockSudokuGridVertical = safeBlockVertical! * 0.75;
    }

    safeBlockSudokuGridVertical =
        min(safeBlockVertical! * 0.66, safeBlockHorizontal!);

// HMI height shall take the remaining space
    safeBlockHMIGridVertical = min(
        (safeBlockVertical! -
            safeBlockSudokuGridVertical! -
            safeBlockAppBarGridVertical!),
        80.0); // Not smaller than aprox. 2cm

    safeBlockAppBarGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockSudokuGridHorizontal =
        safeBlockSudokuGridVertical!; // Grid shall be a square.

// Button min / max sizes :
    Logger.root.level = Level.ALL;

    log.info(
        'Horizontal size of screen in pixel: $SizeConfig.blockSizeHorizontal.toString()');
    log.info(
        'Vertical size of screen in pixel: $SizeConfig.blockSizeVertical.toString()');
    log.info(
        'Horizontal safe size of screen in pixel: $SizeConfig.safeBlockHorizontal.toString()');
    log.info(
        'Vertical safe size of screen in pixel: $SizeConfig.safeBlockVertical.toString()');
    log.info('AppBar height in pixel: $safeBlockAppBarGridVertical.toString()');
    log.info('Sudoku height in pixel: $safeBlockSudokuGridVertical.toString()');
    log.info('HMI height in pixel: $safeBlockHMIGridVertical.toString()');
  }
}

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
class DataProvider with ChangeNotifier {
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
    // writeFullMatrixToRust();
    // callRustUpdate();
    // readMatrixFromRust();
    /* After the Rust processing update */
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////////////////
  // RUST FFI Backend Interface :
  // Backend section. Store matrix state  in backend.
  // only data is stored. The visual highlighting state is not stored in the backend

  late final RustMatrix rustMatrix;
  late List<List<DartToRustElement>> dartMatrix;

  DataProvider() {
    // link the Rust library
    // create the Rust matrix
    // and create a Dart SnapShot .
    _initMatrix();
  }

  // -------------------------------
  // Rust matrix initialization
  // -------------------------------
  void _initMatrix() {
    final dylib = Platform.isAndroid
        ? DynamicLibrary.open('librust_backend.so')
        : Platform.isWindows
            ? DynamicLibrary.open('rust_backend.dll')
            : Platform.isMacOS
                ? DynamicLibrary.open('librust_backend.dylib')
                : DynamicLibrary.open('librust_backend.so');

    // Create Rust matrix interface class instance
    rustMatrix = RustMatrix(dylib, constSudokuNumRow, constSudokuNumCol);

    // Initialize a Dart-side matrix and write a snapshot
    dartMatrix = rustMatrix.readMatrixFromRust();
  }

  RequestedCandHighLightType _requestedCandHighLightType =
      List<int>.from(constRequestedCandHighLightType);

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
  void writeCellToRust(int r, int c) {
    // Write into FFI interface class
    rustMatrix.writeCellToRust(rustMatrix.ptr, dartMatrix, r, c);
  }

  // -------------------------------
  // Full Dart → Rust sync
  // -------------------------------
  void writeFullMatrixToRust() {
    // Write into FFI interface class
    rustMatrix.writeMatrixToRust(
        rustMatrix.ptr, dartMatrix, rustMatrix.rows, rustMatrix.cols);
  }

  // -------------------------------
  // Single-cell Rust → Dart update
  // -------------------------------
  void readCellFromRust(int r, int c) {
    dartMatrix[r][c] = rustMatrix.readCellFromRust(r, c);
  }

  // -------------------------------
  // Read candidate pattern highlighting tyep from RUST
  // -------------------------------
  int readRequestedCandHighLightTypeFromRust(int r, int c, int cand) {
    dartMatrix[r][c] = rustMatrix.readCellFromRust(r, c);

    int _patternRequest_int = constPatternListOff;

    _patternRequest_int = dartMatrix[r][c].requestedCandHighLightType[cand - 1];

    return _patternRequest_int;
  }

  // -------------------------------
  // Full Rust → Dart update
  // -------------------------------
  void readMatrixFromRust() {
    // Update full snapshot from Rust
    dartMatrix = rustMatrix.readMatrixFromRust();
  }

  // -------------------------------
  // Call Rust update function
  // -------------------------------
  void callRustUpdate() {
    rustMatrix.update();
  }

  // -------------------------------
  // Debug print
  // -------------------------------
  void printDebug() {
    rustMatrix.printRustAllElements();
  }

  // -------------------------------
  // Dispose / cleanup
  // -------------------------------
  @override
  // is automatically called by ChangeNotifierProvider
  void dispose() {
    rustMatrix.dispose(); // FFI memory cleanup
    super.dispose();
  }
}

////////////////////////////////////////////////////////////
// Main classe  -> root
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TulliSudoku',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

////////////////////////////////////////////////////////////
// Homepage screen . This is the overall root screen
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // obtain current size of App on screen

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: SizeConfig.safeBlockAppBarGridVertical!, // 5 percent
          title: const Text('Tulli Sudoku'),
          // Top bar button list is defined is seperate class
          actions: [appBarActions()]),
      // _appBarActions
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Align children vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align children horizontall
        children: [
          Container(
            height: SizeConfig.safeBlockSudokuGridVertical!,
            width: SizeConfig.safeBlockSudokuGridHorizontal!,
            color: Colors.orange,
            child: const SudokuGrid(),
          ),
          Expanded(
              child: Container(
            height: SizeConfig
                .safeBlockHMIGridVertical!, // what remaines if appbar and sudokugrid is placed
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.blue,
            child: ToggleButtonsSample(),
          ))
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////
/// App top bar
//////////////////////////////////////////////////////////////////////////
class appBarActions extends StatefulWidget {
  const appBarActions({super.key});

  @override
  State<appBarActions> createState() => _appBarActions();
}

class _appBarActions extends State<appBarActions> {
  SelectAddRemoveList _selectAddRemoveListNewData = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    SudokuItem? _selectedSudoku;

    SampleItem? selectedItem;
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PopupMenuButton<SudokuItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: _selectedSudoku,
              onSelected: (SudokuItem _sudokuItem) {
                setState(() {
                  _selectedSudoku = _sudokuItem;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SudokuItem>>[
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemOne, child: Text('Sudoku 1')),
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemTwo, child: Text('Sudoku 2')),
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemThree, child: Text('Sudoku 3')),
                  ]),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
              // The button that is tapped is set to true, and the others to false.
              for (int i = 0; i < _selectAddRemoveListNewData.length; i++) {
                _selectAddRemoveListNewData[i] = i == index;
              }
              Provider.of<DataProvider>(context, listen: false)
                  .updateDataselectAddRemoveList(_selectAddRemoveListNewData);
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            selectedBorderColor: Colors.blue[700],
            selectedColor: Colors.white,
            fillColor: Colors.blue[200],
            color: Colors.blue[400],
            constraints: const BoxConstraints(
              minHeight: 20.0,
              minWidth: 80.0,
              // maxHeight: 60.0,
              // maxWidth: SizeConfig.safeBlockHorizontal!,
            ),
            isSelected: _selectAddRemoveListNewData,
            children: addRemoveList,
          ),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
        ]);
  }
}

/// @startuml
///
/// class SudokuGrid {
///   +build(context) : Widget
/// }
///
/// class SudokuBlock {
///   +build(context) : Widget
/// }
///
/// SudokuGrid *-- SudokuBlock : contains 9
///
/// note right of SudokuGrid
///   Represents the entire Sudoku board.
///   - A 3x3 grid of SudokuBlock.
///   - Each SudokuBlock will itself
///     render a 3x3 set of cells.
/// end note
///
/// note right of SudokuBlock
///   Represents one 3x3 section
///   inside the SudokuGrid.
/// end note
///
/// class SudokuElement {
///  +createState() : _SudokuElementState
/// }
///
/// SudokuBlock *-- SudokuElement : contains 9
/// class _SudokuElementState {
///   -_selectedNumberListNewData : SelectedNumberList[9]
///   -_selectedSetResetListNewData : SelectedSetResetList[4]
///   -_selectedPatternListNewData : SelectedPatternList[5]
///   -_selectedUndoIconListNewData : SelectedUndoIconList[2]
///
///   -_subelementChoiceState : bool
///   -_subelementNumberChoice : int
///   -_numberBackGroundColor : Color
///   -_subelementlistCandidateChoice : bool[9]
///
///   +build(context) : Widget
/// }
/// class InkWell {
///   +onTap() : void
/// }
///
/// class Container
/// class DataProvider
///
/// SudokuElement --|> StatefulWidget
/// _SudokuElementState --|> State
/// SudokuElement --> _SudokuElementState : creates
/// _SudokuElementState *-- InkWell
/// InkWell *-- Container
/// _SudokuElementState --> DataProvider : consumes
///
/// note right of SudokuElement
///   A custom Sudoku cell widget.
///
/// end note
///
/// note right of _SudokuElementState
///   Holds UI state and HMI input variables.
///   subelement_ChoiceState: bool, Number chosen = TRUE, only candidates = FALSE
///   subelement_NumberChoice: Chosen Number (1...9)
///   subelementlist_CandidateChoice[0, ..., 8]: Chosen Candidate Numbers -1 (boolean)
/// end note
///
/// note right of InkWell
///   Handles tap gesture via onTap().
/// end note
/// @enduml
//////////////////////////////////////////////////////////////////////////
/// Sudoku grid
//////////////////////////////////////////////////////////////////////////

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(1),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: const <Widget>[
          // const. list since IDs known at compile time.
          // int block_id : Unique ID of the block [0...8]
          SudokuBlock(block_id: 0),
          SudokuBlock(block_id: 1),
          SudokuBlock(block_id: 2),
          SudokuBlock(block_id: 3),
          SudokuBlock(block_id: 4),
          SudokuBlock(block_id: 5),
          SudokuBlock(block_id: 6),
          SudokuBlock(block_id: 7),
          SudokuBlock(block_id: 8),
        ],
      ),
    );
  }
}

class SudokuBlock extends StatelessWidget {
  final int block_id; // Unique ID of the block [0...8]

  const SudokuBlock({super.key, required this.block_id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(1),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: <Widget>[
          // dyn. list since IDs not known at compile time.
          // int element_id :  Unique ID of the element [0...80]
          // int row : index ~/ 9;
          // int col : index % 9;
          SudokuElement(element_id: block_id * constSudokuNumRow + 0),
          SudokuElement(element_id: block_id * constSudokuNumRow + 1),
          SudokuElement(element_id: block_id * constSudokuNumRow + 2),
          SudokuElement(element_id: block_id * constSudokuNumRow + 3),
          SudokuElement(element_id: block_id * constSudokuNumRow + 4),
          SudokuElement(element_id: block_id * constSudokuNumRow + 5),
          SudokuElement(element_id: block_id * constSudokuNumRow + 6),
          SudokuElement(element_id: block_id * constSudokuNumRow + 7),
          SudokuElement(element_id: block_id * constSudokuNumRow + 8),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////
/// Sudoku grid element
//////////////////////////////////////////////////////////////////////////
class SudokuElement extends StatefulWidget {
  final int element_id; // Unique ID of the element [0...80]
  // int row = index ~/ 9;
  // int col = index % 9;

  const SudokuElement({super.key, required this.element_id});

  @override
  State<SudokuElement> createState() => _SudokuElementState();
}

class _SudokuElementState extends State<SudokuElement> {
  // HMI input variables

  SelectedNumberList _selectedNumberListNewData =
      List<bool>.from(constSelectedNumberList);

  SelectedSetResetList _selectedSetResetListNewData =
      List<bool>.from(constSelectedSetResetList);

  SelectedPatternList _selectedPatternListNewData =
      List<bool>.from(constSelectedPatternList);

  SelectedUndoIconList _selectedUndoIconListNewData =
      List<bool>.from(constSelectedUndoIconList);

  //  End HMI input variables////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////
  /* state variables :
  subelement_ChoiceState: bool, Number chosen = TRUE, only candidates = FALSE
  subelement_NumberChoice: Chosen Number (1...9)
  subelementlist_CandidateChoice[0, ..., 8]: Chosen Candidate Numbers -1 (boolean)
  */
  bool _subelementChoiceState = false; // No choice made

  var _subelementNumberChoice = 0; // Init value 0

  Color _numberBackGroundColor = Color(0xFFFFFFFF); // white number background

  SelectedCandList _subelementlistCandidateChoice =
      List<bool>.from(constSelectedCandList);

  RequestedCandHighLightType _requestedCandHighLightTypeNewData =
      List<int>.from(constRequestedCandHighLightType);

// return 0 : no number set
  int _readNumberFromList(SelectedNumberList selectedNumberList) {
    int number = 0;

    // Check which number is selected (corresponding bit is TRUE)
    for (int i = 0; i < selectedNumberList.length; i++) {
      if (selectedNumberList[i] == true) {
        number = i + 1;
      } else {
        // Add error handling here ...
      }
    }

    return number;
  }

  void _setNumber(int number) {
    setState(() {
      // Update HMI
      _subelementChoiceState = true;
      _subelementNumberChoice = number;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // FFI RUST interface call  to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false)
          .writeCellToRust(_pos.row, _pos.col);
    });
  }

  void _resetNumber(int number) {
    setState(() {
      _subelementChoiceState = false;
      _subelementNumberChoice = 0;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false)
          .writeCellToRust(_pos.row, _pos.col);
    });
  }

  void _setCandidate(int number) {
    setState(() {
      if (number > 0) {
        _subelementlistCandidateChoice[number - 1] = true;

        // Extract col and row from unique ID
        GridPosition _pos =
            getRowColFromId(widget.element_id, constSudokuNumRow);

        //  FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
        Provider.of<DataProvider>(context, listen: false)
            .writeCellToRust(_pos.row, _pos.col);
      }
    });
  }

  void _resetCandidate(int number) {
    setState(() {
      _subelementlistCandidateChoice[number - 1] = false;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false)
          .writeCellToRust(_pos.row, _pos.col);
    });
  }

  bool _checkCandidate(int number) {
    if (number == 0) {
      return false;
    } else if (_subelementlistCandidateChoice[number - 1] == true) {
      return true;
    } else {
      return false;
    }
  }

  bool _checkCandidatePatternRequestType(
      int cand_number, int patternCandRequest) {
    // Extract col and row from unique ID
    GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

    // Extract requested hightlight pattern for current candidate
    int _patternTypeRequest = Provider.of<DataProvider>(context, listen: false)
        .readRequestedCandHighLightTypeFromRust(
            _pos.row, _pos.col, cand_number);

    bool _check_bool = (_subelementChoiceState ==
            false) && // Check if Number is already chosen for Element
        (_subelementlistCandidateChoice[cand_number - 1] ==
            true) && // Check if Candidate is chosen
        (_patternTypeRequest ==
            patternCandRequest); // Check if HighLight request type is active

    if (cand_number == 0) {
      return false;
    } else if (_check_bool == true) {
      return true;
    } else {
      return false;
    }
  }

  Color _getNumberBackgroundColor() {
    Color _color = Color(0xFFFFFFFF); // opac white
    int _numberHMI = _readNumberFromList(_selectedNumberListNewData);

    setState(() {
      if ((_selectedPatternListNewData[PatternList.hiLightOn] ==
              true) && // Highlighting is switched ON on HMI
          (_subelementChoiceState == true) && // Numner is chosen in Grid
          (_subelementNumberChoice ==
              _numberHMI)) // Numner on HMI corresponds to Number in Grid
      {
        _color = const Color.fromARGB(255, 5, 255, 243);
      } // highlighting on
      else if ((_selectedPatternListNewData[PatternList.hiLightOn] ==
              true) && // Highlighting is switched ON on HMI
          (_subelementChoiceState == false) && // Numner is NOT chosen in Grid
          (_checkCandidate(_numberHMI) ==
              true)) // Numner on HMI corresponds to Candidate Number in Grid
      {
        _color = const Color.fromARGB(255, 5, 255, 243);
      } else if ((_selectedPatternListNewData[PatternList.pairs] ==
              true) && // Highlighting is switched ON on HMI
          _checkCandidatePatternRequestType(
                  _subelementNumberChoice, PatternList.pairs) ==
              true) {
        _color = const Color.fromARGB(255, 5, 255, 18);
      } // green highlighting
      else {
        _color = const Color(0xFFFFFFFF); // keep white
      }
    });

    // Add FFI RUST interface call here to read data from RUST FFI (Display / Highlight color)
    return _color;
  }

  void _updateElementState(
      SelectedNumberList selectedNumberList, SelectedSetResetList actionlist) {
    setState(() {
      int candNumber = 0;

      candNumber = _readNumberFromList(selectedNumberList);

      // Case 0 : User wants to add a candidate number
      if (actionlist[0] == true) {
        _setCandidate(candNumber);
        // Case 1 : User wants to remove a candidate number
      } else if (actionlist[1] == true) {
        _resetCandidate(candNumber);
        // Case 2 : User wants to add a  number
      } else if (actionlist[2] == true) {
        _setNumber(candNumber);
        // Case 3 : User wants to remove a number
      } else if (actionlist[3] == true) {
        _resetNumber(candNumber);
        // Case 4 : ELSE: error
      } else {
        Logger.root.level = Level.ALL;
        log.shout('if actionlist[] entered unintended ELSE statement');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // receive data from data provider triggered by HMI
    _selectedNumberListNewData =
        Provider.of<DataProvider>(context)._selectedNumberList;
    _selectedSetResetListNewData =
        Provider.of<DataProvider>(context)._selectedSetResetList;
    _selectedPatternListNewData =
        Provider.of<DataProvider>(context)._selectedPatternList;
    _selectedUndoIconListNewData =
        Provider.of<DataProvider>(context)._selectedUndoIconList;
    _requestedCandHighLightTypeNewData =
        Provider.of<DataProvider>(context)._requestedCandHighLightType;

    return InkWell(
        onTap: () {
          setState(() {
            _updateElementState(
                _selectedNumberListNewData, _selectedSetResetListNewData);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(1.0),
          color: Colors.blue[600],
          alignment: Alignment.center,
          child: !_subelementChoiceState // Result Number chosen ?
              ? GridView.count(
                  primary: true, // no scrolling
                  padding: const EdgeInsets.all(0.5),
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(), // no scrolling
                  childAspectRatio:
                      1.0, // horozontal verus vertical aspect ratio
                  children: <Widget>[
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[0] == true)
                              ? Text("1",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("1",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[1] == true)
                              ? Text("2",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("2",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[2] == true)
                              ? Text("3",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("3",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[3] == true)
                              ? Text("4",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("4",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[4] == true)
                              ? Text("5",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("5",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[5] == true)
                              ? Text("6",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("6",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[6] == true)
                              ? Text("7",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("7",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[7] == true)
                              ? Text("8",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.bold))
                              : Text("8",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[8] == true)
                              ? Text("9",
                                  style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor:
                                          _getNumberBackgroundColor(),
                                      fontWeight: FontWeight.w900))
                              : Text("9",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                  ],
                )
              : Container(
                  //  padding: const EdgeInsets.all(1),
                  alignment: Alignment.center,
                  color: const Color.fromARGB(255, 235, 252, 250),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text('$_subelementNumberChoice',
                          style: TextStyle(
                              color: Colors.black,
                              backgroundColor: _getNumberBackgroundColor(),
                              fontWeight: FontWeight.w900))),
                ),
        ));
  }
}

//////////////////////////////////////////////////////////////////////////
/// HMI / buttons
//////////////////////////////////////////////////////////////////////////

class ToggleButtonsSample extends StatefulWidget {
  const ToggleButtonsSample({super.key});

  @override
  State<ToggleButtonsSample> createState() => _ToggleButtonsSampleState();
}

class _ToggleButtonsSampleState extends State<ToggleButtonsSample> {
///////////////////////////////////////////////////
  /// State HMI variables :
  ///
  // HMI Number selection input

  SelectedNumberList _selectedNumberList =
      List<bool>.from(constSelectedNumberList);

  SelectedSetResetList _selectedSetResetList =
      List<bool>.from(constSelectedSetResetList);

  SelectedPatternList _selectedPatternList =
      List<bool>.from(constSelectedPatternList);

  SelectedUndoIconList _selectedUndoIconList =
      List<bool>.from(constSelectedUndoIconList);

  // variable to calculate max. size of button list
  double selectedNumberListWidthMax = 0.0;
  double selectedSetResetListWidthMax = 0.0;
  double selectedPatternListWidthMax = 0.0;
  double selectedUndoIconListWidthMax = 0.0;

  final bool _vertical = false; // constant setting

// State HMI variables END
///////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Dimension apply to individual buttons, thus must be divided by number of buttons in the array
    selectedNumberListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedNumberList.length);

    selectedSetResetListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedSetResetList.length); // for futur use if required.

    selectedPatternListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedPatternList.length); // for futur use if required.

    selectedUndoIconListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedUndoIconList.length); // for futur use if required.

    Logger.root.level = Level.ALL;
    log.info(
        'selectedNumberListWidthMax: $selectedNumberListWidthMax.toString()');
    log.info(
        'selectedSetResetListWidthMax: $selectedSetResetListWidthMax.toString()');
    log.info(
        'selectedPatternListWidthMax: $selectedPatternListWidthMax.toString()');
    log.info(
        'selectedUndoIconListWidthMax: $selectedUndoIconListWidthMax.toString()');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(), // no scrolling
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ToggleButtons with a single selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedSetResetList.length; i++) {
                      _selectedSetResetList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedSetResetList(_selectedSetResetList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedSetResetList,
                children: setresetlist,
              ),
              // ToggleButtons with a multiple selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    _selectedPatternList[index] = !_selectedPatternList[index];
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedPatternList(_selectedPatternList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedPatternList,
                children: patternlistButtonList,
              ),
              // ToggleButtons with icons only.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedUndoIconList.length; i++) {
                      _selectedUndoIconList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedUndoIconList(_selectedUndoIconList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedUndoIconList,
                children: undoiconlist,
              ),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedNumberList.length; i++) {
                      _selectedNumberList[i] = i == index;
                      // Update data in the provider
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataNumberlist(_selectedNumberList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: BoxConstraints(
                  minHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  maxHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  minWidth: selectedNumberListWidthMax,
                  maxWidth: selectedNumberListWidthMax,
                ),
                isSelected: _selectedNumberList,
                children: numberlist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Copyright 2025, Mirko THULKE, Versailles
