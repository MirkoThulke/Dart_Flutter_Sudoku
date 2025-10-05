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

import 'package:flutter/material.dart'; // basics
import 'package:provider/provider.dart'; // data excahnge between classes
import 'package:logging/logging.dart'; // logging

// Import specific dart files
import 'package:sudoku/utils/export.dart';

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

  SelectedAddRemoveList _selectedAddRemoveListNewData =
      List<bool>.from(constSelectedAddRemoveList);

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

  @override
  void initState() {
    super.initState();

    // Keep initState() only for local constant initialization:

    // Check which number is selected (corresponding bit is TRUE)
    assert(widget.element_id <= 80, 'element_id exceeds maximum allowed size!');
    assert(widget.element_id >= 0, 'element_id equals 0 or negative!');

    // Initialize lists from constants
    _numberBackGroundColor = Color(0xFFFFFFFF); // optional: keep default
    _selectedNumberListNewData = List<bool>.from(constSelectedNumberList);
    _selectedSetResetListNewData = List<bool>.from(constSelectedSetResetList);
    _selectedPatternListNewData = List<bool>.from(constSelectedPatternList);
    _selectedUndoIconListNewData = List<bool>.from(constSelectedUndoIconList);
    _selectedAddRemoveListNewData = List<bool>.from(constSelectedAddRemoveList);
    _subelementlistCandidateChoice = List<bool>.from(constSelectedCandList);
    _requestedCandHighLightTypeNewData =
        List<int>.from(constRequestedCandHighLightType);
  }

/* Initialize from provider in didChangeDependencies() :
didChangeDependencies() is called after the widget is inserted into the widget tree.
Provider.of(context) works here safely.
_initialized ensures the widget doesn’t overwrite state repeatedly if didChangeDependencies() is called multiple times.
setState() forces the widget to rebuild with the newly loaded JSON data.
*/
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dataProvider = Provider.of<DataProvider>(context);

    // Initialize from JSON only once when data is ready
    if (dataProvider.status == DataStatus.ready && !_initialized) {
      _initialized = true; // ensure we only initialize once
      initializeFromJSON();
      setState(() {}); // update the UI after local state is set
    }

    // Compare old vs new to prevent redundant rebuilds
    if (_initialized &&
        checkCellFromDartMirrorForNumberChange(widget.element_id)) {
      initializeFromJSON(); // Read DartMirror
      setState(() {}); // update the UI after local state is set
    }
  }

  void initializeFromJSON() {
    // safe to read data here
    // initialise from JSON here ....
    // Fetch the element data from DataProvider based on element_id

    final DartToRustElement elementDataJSON =
        returnCellFromDartMirror(widget.element_id);

    // Initialize local state from JSON / DataProvider instead of constants
    _subelementNumberChoice = elementDataJSON.selectedNumState;

    if (_subelementNumberChoice > 0) {
      _subelementChoiceState = true;
    } else {
      _subelementChoiceState = false;
    }
    _subelementlistCandidateChoice =
        List<bool>.from(elementDataJSON.selectedCandList);

    _requestedCandHighLightTypeNewData =
        List<int>.from(elementDataJSON.requestedCandHighLightType);
  }

  // -------------------------------
  // Return Cell element from Dart Mirror for Initialisation of the Cell upon App start
  // -------------------------------
  DartToRustElement returnCellFromDartMirror(int element_id) {
    GridPosition _pos = getRowColFromId(element_id, constSudokuNumRow);

    DartToRustElement cellElement =
        Provider.of<DataProvider>(context, listen: false).dartMatrix[_pos.row]
            [_pos.col];

    return cellElement;
  }

  // -------------------------------
  // Return true if Cell element candidate or number from Dart Mirror has changed
  // -------------------------------
  bool checkCellFromDartMirrorForNumberChange(int element_id) {
    GridPosition _pos = getRowColFromId(element_id, constSudokuNumRow);

    final new_cell = returnCellFromDartMirror(widget.element_id);

    return new_cell.selectedNumState != _subelementNumberChoice ||
        new_cell.selectedCandList != _subelementlistCandidateChoice;
  }

// return 0 : no number set
  int _readNumberFromList(SelectedNumberList selectedNumberList) {
    int number = 0;

    // Check which number is selected (corresponding bit is TRUE)
    assert(selectedNumberList.length <= constSelectedCandListSize,
        'selectedNumberList.length exceeds maximum allowed size!');

    for (int i = 0; i < selectedNumberList.length; i++) {
      if (selectedNumberList[i] == true) {
        number = i + 1;
      } else {
        // Add error handling here ...
      }
    }

    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');
    assert(number >= 0, 'number cannot be negative');

    return number;
  }

  void _setNumber(int number) {
    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');

    setState(() {
      // Update HMI
      _subelementChoiceState = true;
      _subelementNumberChoice = number;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // write into Dart Mirror
      Provider.of<DataProvider>(context, listen: false)
          .dartMatrix[_pos.row][_pos.col]
          .selectedNumState = number;

      // FFI RUST interface call  to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false).writeCellToRust(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);

      // FFI RUST interface Cell update call to update the highlight patterns in the Rust memory
      Provider.of<DataProvider>(context, listen: false).callRustCellUpdate(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);
    });
  }

  void _resetNumber(int number) {
    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');

    setState(() {
      _subelementChoiceState = false;
      _subelementNumberChoice = 0;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // write into Dart Mirror
      Provider.of<DataProvider>(context, listen: false)
          .dartMatrix[_pos.row][_pos.col]
          .selectedNumState = 0;

      // FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false).writeCellToRust(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);

      // FFI RUST interface Cell update call to update the highlight patterns in the Rust memory
      Provider.of<DataProvider>(context, listen: false).callRustCellUpdate(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);
    });
  }

  void _setCandidate(int number) {
    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');

    setState(() {
      if (number > 0) {
        _subelementlistCandidateChoice[number - 1] = true;

        // Extract col and row from unique ID
        GridPosition _pos =
            getRowColFromId(widget.element_id, constSudokuNumRow);

        // write into Dart Mirror
        Provider.of<DataProvider>(context, listen: false)
            .dartMatrix[_pos.row][_pos.col]
            .selectedCandList[number - 1] = true;

        //  FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
        Provider.of<DataProvider>(context, listen: false).writeCellToRust(
            _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);

        // FFI RUST interface Cell update call to update the highlight patterns in the Rust memory
        Provider.of<DataProvider>(context, listen: false).callRustCellUpdate(
            _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);
      }
    });
  }

  void _resetCandidate(int number) {
    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');

    setState(() {
      _subelementlistCandidateChoice[number - 1] = false;

      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // write into Dart Mirror
      Provider.of<DataProvider>(context, listen: false)
          .dartMatrix[_pos.row][_pos.col]
          .selectedCandList[number - 1] = false;

      // FFI RUST interface call to write data to RUST FFI (Number and candidate choices)
      Provider.of<DataProvider>(context, listen: false).writeCellToRust(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);

      // FFI RUST interface Cell update call to update the highlight patterns in the Rust memory
      Provider.of<DataProvider>(context, listen: false).callRustCellUpdate(
          _pos.row, _pos.col, constSudokuNumRow, constSudokuNumCol);
    });
  }

  bool _checkCandidate(int number) {
    assert(number <= constSelectedCandListSize,
        'number exceeds maximum allowed size!');

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
    assert(
        (cand_number <= constSelectedCandListSize) ||
            (cand_number == constIntCandList.DEFAULT.value),
        'cand_number exceeds maximum allowed size! $cand_number');
    assert(
        (patternCandRequest <= constIntPatternList.user.value) ||
            (patternCandRequest == constIntPatternList.DEFAULT.value),
        'patternCandRequest exceeds maximum allowed size! $patternCandRequest');
    assert(widget.element_id <= 80,
        'widget.element_id exceeds maximum allowed size! $widget.element_id');

    if (cand_number == 0 || cand_number == constIntCandList.DEFAULT.value) {
      return false;
    } else if (cand_number < 1 || cand_number > constSelectedCandListSize) {
      throw RangeError('cand must be between 1 and 9, got $cand_number');
    } else {
      // Extract col and row from unique ID
      GridPosition _pos = getRowColFromId(widget.element_id, constSudokuNumRow);

      // Extract requested hightlight pattern for current candidate
      int _patternTypeRequest =
          Provider.of<DataProvider>(context, listen: false)
              .readRequestedCandHighLightTypeFromRust(_pos.row, _pos.col,
                  cand_number, constSudokuNumRow, constSudokuNumCol);

      bool _check_bool = (_subelementChoiceState ==
              false) && // Check if Number is already chosen for Element
          (_subelementlistCandidateChoice[cand_number - 1] ==
              true) && // Check if Candidate is chosen
          (_patternTypeRequest ==
              patternCandRequest); // Check if HighLight request type is active

      return _check_bool;
    }
  }

  Color _getNumberBackgroundColor(int numCandCellToCheck) {
    Color _color = Color.fromARGB(255, 255, 255, 255); // opac white

    int _numberHMI = _readNumberFromList(_selectedNumberListNewData);

    assert(_numberHMI <= constSelectedCandListSize,
        '_numberHMI exceeds maximum allowed size!');
    assert(_selectedPatternListNewData.length <= constSelectedPatternListSize,
        '_selectedPatternListNewData.lengthexceeds maximum allowed size!');
    assert(constIntPatternList.hiLightOn.value <= constPatternListMaxIndex,
        'constIntPatternList.hiLightOn.value exceeds maximum allowed size!');
    assert(constIntPatternList.pairs.value <= constPatternListMaxIndex,
        'constIntPatternList.pairs.value exceeds maximum allowed size!');

    setState(() {
      _color = const Color.fromARGB(255, 235, 252, 250); // keep  default

      ////////////////////////////////////////////////////////////
      // Check constIntPatternList.hiLightOn.value
      if ((_selectedPatternListNewData[constIntPatternList.hiLightOn.value] ==
              true) && // Highlighting is switched ON on HMI
          (_subelementChoiceState == true) && // Numner is chosen in Grid
          (_subelementNumberChoice ==
              _numberHMI)) // Numner on HMI corresponds to Number in Grid
      {
        _color = const Color.fromARGB(255, 5, 255, 243);
      } // highlighting on
      else if ((_selectedPatternListNewData[
                  constIntPatternList.hiLightOn.value] ==
              true) && // Highlighting is switched ON on HMI
          (_subelementChoiceState == false) && // Numner is NOT chosen in Grid
          (_checkCandidate(numCandCellToCheck) ==
              true) && // Cand is chosen in Cell
          (numCandCellToCheck ==
              _numberHMI)) // Numner on HMI corresponds to Candidate Number in Cell
      {
        _color = const Color.fromARGB(255, 4, 252, 239);
      } // green highlighting
      else {
        // do nothing, keep default color
      }

      ////////////////////////////////////////////////////////////////////
      // Check constIntPatternList.pairs.value

      if ((_selectedPatternListNewData[constIntPatternList.pairs.value] ==
              true) && // Highlighting is switched ON on HMI
          _checkCandidatePatternRequestType(
                  numCandCellToCheck, constIntPatternList.pairs.value) ==
              true) {
        _color = const Color.fromARGB(255, 118, 255, 5);
      } else {
        // do nothing, keep default color
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
      assert(candNumber <= constSelectedCandListSize,
          '_numberHMI exceeds maximum allowed size!');

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
    // Update build() to show spinner until data is ready
    final dataProvider = Provider.of<DataProvider>(context);

    if (!_initialized || dataProvider.status != DataStatus.ready) {
      return const Center(child: CircularProgressIndicator());
    }
    // receive data from data provider triggered by HMI
    _selectedNumberListNewData =
        Provider.of<DataProvider>(context).selectedNumberList;
    _selectedSetResetListNewData =
        Provider.of<DataProvider>(context).selectedSetResetList;
    _selectedPatternListNewData =
        Provider.of<DataProvider>(context).selectedPatternList;
    /*_selectedUndoIconListNewData =
        Provider.of<DataProvider>(context).selectedUndoIconList; */
    /* _selectedAddRemoveListNewData =
        Provider.of<DataProvider>(context).selectedAddRemoveList; */
    _requestedCandHighLightTypeNewData =
        Provider.of<DataProvider>(context).requestedCandHighLightType;

    return InkWell(
      onTap: () {
        setState(() {
          _updateElementState(
            _selectedNumberListNewData,
            _selectedSetResetListNewData,
          );
        });
      },
      child: Container(
        color: const Color.fromARGB(255, 159, 203, 248),
        width: 1, // outer line thickness
        padding: const EdgeInsets.all(1),
        alignment: Alignment.center,
        child: !_subelementChoiceState
            ?
            // GridView branch
            GridView.count(
                primary: true,
                padding: EdgeInsets.zero,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: List.generate(9, (index) {
                  final candidateActive = _subelementlistCandidateChoice[index];
                  final numberText = constTextNumList.values[index].text;
                  final numberValue = constIntCandList.values[index].value;

                  return Container(
                    color: const Color.fromARGB(255, 235, 252, 250),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit
                          .fill, // fills the cell both vertically and horizontally
                      child: Text(
                        numberText,
                        style: TextStyle(
                          fontFamily: 'Impact',
                          fontWeight: candidateActive
                              ? FontWeight.w900
                              : FontWeight.normal,
                          color: candidateActive
                              ? Colors.black
                              : Colors.black.withOpacity(0.2),
                          backgroundColor: candidateActive
                              ? _getNumberBackgroundColor(numberValue)
                              : null,
                          fontSize: 200, // starting huge, FittedBox scales
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              )
            : Container(
                color: const Color.fromARGB(255, 235, 252, 250),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(
                      2.0), // adjust this value for more or less spacing
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      '$_subelementNumberChoice',
                      style: TextStyle(
                        fontFamily: 'Impact',
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        backgroundColor: _getNumberBackgroundColor(
                            constIntCandList.DEFAULT.value),
                        fontSize: 200,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// Copyright 2025, Mirko THULKE, Versailles
