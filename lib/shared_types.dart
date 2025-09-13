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

import 'package:flutter/material.dart';

/// @startuml
/// class SelectedSetResetList {
///   + setCand : bool
///   + resetCand : bool
///   + setNum : bool
///   + resetNum, : bool
/// }
/// note right of SelectedSetResetList::setCand
///   set cell candidate number. Each cell can hold numbers 1..9 as candidates.
/// end note
///
/// note right of SelectedSetResetList::resetCand
///   reset candidate number
/// end note
///
/// note right of SelectedSetResetList::setNum
///   each cell can alternatively hold exactly one nubmer as result Number
/// end note
///
/// note right of SelectedSetResetList::resetNum
///   Reset the final number choice of this cell
/// end note
/// @enduml

/////////////////////////////////////
// constants
/////////////////////////////////////
const int constSudokuNumRow = 9;
const int constSudokuNumCol = 9;

// types
typedef SelectedNumberList = List<bool>;
typedef SelectedCandList = List<bool>;
typedef SelectedSetResetList = List<bool>;
typedef SelectedPatternList = List<bool>;
typedef RequestedElementHighLightType = List<bool>;
typedef RequestedCandHighLightType = List<int>;
typedef SelectedUndoIconList = List<bool>;
typedef SelectAddRemoveList = List<bool>;

// Hardcoded List sizes of above types
const int constSelectedNumberListSize = 9;
const int constSelectedCandListSize = 9;
const int constSelectedSetResetListSize = 4;
const int constSelectedPatternListSize = 5;
const int constRequestedElementHighLightTypeListSize = 5;
const int constRequestedCandHighLightTypeListSize = 9;
const int constSelectedUndoIconListSize = 2;
const int constSelectAddRemoveListSize = 2;

// constant arrays for initialisation
const List<bool> constSelectedNumberList = [
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
];
const List<bool> constSelectedCandList = constSelectedNumberList;

const List<Widget> numberlist = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
  Text('4'),
  Text('5'),
  Text('6'),
  Text('7'),
  Text('8'),
  Text('9')
];

const List<Widget> setresetlist = <Widget>[
  Text('SetCand'),
  Text('ResetCand'),
  Text('SetNum'),
  Text('ResetNum')
];

const List<bool> constSelectedSetResetList = [true, false, false, false];

const List<Widget> patternlistButtonList = <Widget>[
  Text('HiLightOn'),
  Text('Pairs'),
  Text('MatchPairs'),
  Text('Twins'),
  Text('User'),
];

const List<bool> constSelectedPatternList = [
  false,
  false,
  false,
  false,
  false,
];

class PatternList {
  static const int hiLightOn = 0;
  static const int pairs = 1;
  static const int matchPairs = 2;
  static const int twins = 3;
  static const int user = 4;
}

// Special derived/off state
const int constPatternListOff = 255;

const List<bool> constRequestedElementHighLightType = [
  false,
  false,
  false,
  false,
  false
];

const List<int> constRequestedCandHighLightType = [
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff,
  constPatternListOff
];

const List<Widget> undoiconlist = <Widget>[
  Icon(Icons.undo),
  Icon(Icons.redo),
];

const List<bool> constSelectedUndoIconList = [false, false];

class undoiconlistIndex {
  static const int undo = 0;
  static const int redo = 1;
}

const List<Widget> addRemoveList = <Widget>[
  Icon(Icons.add_box_outlined),
  Icon(Icons.remove_circle_outline),
];

const List<bool> constSelectAddRemoveList = [false, false];

class addRemoveListIndex {
  static const int add = 0;
  static const int remove = 1;
}

// This is the type used by the popup menu below.
enum SudokuItem { itemOne, itemTwo, itemThree }

class SudokuItemIndex {
  static const int add = 0;
  static const int remove = 1;
}

// This is the type used by the popup menu below.
enum SampleItem { itemOne, itemTwo, itemThree }

class SampleItemIndex {
  static const int add = 0;
  static const int remove = 1;
}

/*
const List<Widget> saveCreateList = <Widget>[
  Icon(Icons.list_alt_rounded),
  Icon(Icons.add_box_outlined),
  Icon(Icons.remove_circle_outline),
  Icon(Icons.settings_applications_outlined),
  Icon(Icons.info_outline_rounded),
  Icon(Icons.exit_to_app_sharp),
];
*/
/////////////////////////////////////

/////////////////////////////////////
// Global helper functions
/////////////////////////////////////

class GridPosition {
  final int row;
  final int col;

  GridPosition(this.row, this.col);
}

/*
ID: 0 → row 0, col 0
ID: 1 → row 0, col 1
ID: 2 → row 0, col 2
ID: 3 → row 1, col 0
ID: 4 → row 1, col 1
ID: 5 → row 1, col 2
...
*/
GridPosition getRowColFromId(int id, int numColumns) {
  // int element_id :  Unique ID of the element [0...80]
  int row = id ~/ numColumns;
  int col = id % numColumns;

  return GridPosition(row, col);
}
/*
row = 0 is the first row
col = 0 is the first column

void main() {
  int id = 7;
  int numColumns = 3;
  
  GridPosition pos = getRowColFromId(id, numColumns);
  print("Row: ${pos.row}, Column: ${pos.column}"); // Row: 2, Column: 1
}

*/
