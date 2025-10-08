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
///
///
///
///
// Acticate JSON file storage an external Device Memory .
// Only allowed during debugging testing !
const bool DEBUG_JSON = true;

const int CONST_MATRIX_SIZE = 9;
const int CONST_MATRIX_ELEMENTS = 81;
const int MAX_UINT8 = 255;

// to handle app states
enum DataStatus { loading, ready, error }

const int constSudokuNumRow = CONST_MATRIX_SIZE;
const int constSudokuNumCol = CONST_MATRIX_SIZE;

// types
typedef SelectedNumberList = List<bool>;
typedef SelectedNumStateList = List<bool>;
typedef SelectedCandList = List<bool>;
typedef SelectedSetResetList = List<bool>;
typedef SelectedPatternList = List<bool>;
typedef RequestedElementHighLightType = List<bool>;
typedef RequestedCandHighLightType = List<int>;
typedef SelectedUndoIconList = List<bool>;
typedef SelectedAddRemoveList = List<bool>;

// Hardcoded List sizes of above types
const int constSelectedNumberListSize = CONST_MATRIX_SIZE;
const int constSelectedNumStateListSize = 2;
const int constSelectedCandListSize = CONST_MATRIX_SIZE;
const int constSelectedSetResetListSize = 4;
const int constSelectedPatternListSize = 4;
const int constRequestedElementHighLightTypeListSize = 5;
const int constRequestedCandHighLightTypeListSize = CONST_MATRIX_SIZE;
const int constSelectedUndoIconListSize = 2;
const int constSelectedAddRemoveListSize = 4;

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

enum constIntNumList {
  ONE(1),
  TWO(2),
  THREE(3),
  FOUR(4),
  FIVE(5),
  SIX(6),
  SEVEN(7),
  EIGHT(8),
  NINE(9),
  DEFAULT(255);

  final int value;
  const constIntNumList(this.value);
}

enum constIntCandList {
  ONE(1),
  TWO(2),
  THREE(3),
  FOUR(4),
  FIVE(5),
  SIX(6),
  SEVEN(7),
  EIGHT(8),
  NINE(9),
  DEFAULT(255);

  final int value;
  const constIntCandList(this.value);
}

enum constTextNumList {
  ONE("1"),
  TWO("2"),
  THREE("3"),
  FOUR("4"),
  FIVE("5"),
  SIX("6"),
  SEVEN("7"),
  EIGHT("8"),
  NINE("9"),
  DEFAULT("255");

  final String text;
  const constTextNumList(this.text);
}

enum SudokuNumber {
  one(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9);

  final int value;
  const SudokuNumber(this.value);

  String get display => value.toString();
}

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
  Text('Singles'),
  Text('Givens'),
];

const List<bool> constSelectedPatternList = [
  false,
  false,
  false,
  false,
];

class PatternList {
  static const int hiLightOn = 0;
  static const int pairs = 1;
  static const int singles = 2;
  static const int givens = 3;
}

enum constIntPatternList {
  hiLightOn(0),
  pairs(1),
  singles(2),
  givens(3),
  DEFAULT(255);

  final int value;
  const constIntPatternList(this.value);
}

const int constPatternListMaxIndex = PatternList.givens;

// Special derived/off state
const int constPatternListOff = MAX_UINT8;

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

const List<bool> constSelectedNumStateList = [false, false];

class SelectedNumStateListIndex {
  static const int Givens = 0;
  static const int FutureUse = 1;
}

const List<Widget> addRemoveList = <Widget>[
  Text('SaveGivens'),
  Text('EraseAll'),
  Text('ResetToGivens'),
  Text('SelectAllCand'),
];

/*
const List<Widget> addRemoveList = <Widget>[
  Icon(Icons.add_box_outlined),
  Icon(Icons.remove_circle_outline),
];
*/

const List<bool> constSelectedAddRemoveList = [false, false, false, false];

class addRemoveListIndex {
  static const int saveGivens = 0;
  static const int eraseAll = 1;
  static const int resetToGivens = 2;
  static const int selectAllCand = 3;
}

// This is the type used by the popup menu below.
enum SudokuItem { itemOne, itemTwo, itemThree }

class SudokuItemIndex {
  static const int itemOne = 0;
  static const int itemTwo = 1;
  static const int itemThree = 2;
}

// This is the type used by the popup menu below.
enum SampleItem { itemOne, itemTwo, itemThree }

class SampleItemIndex {
  static const int itemOne = 0;
  static const int itemTwo = 1;
  static const int itemThree = 2;
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

GridPosition getRowColFromId(int id, int numColumns) {
  /*
   The matrix in Flutter is organised into 9 Sudoku blocks.
   Each block contains 9 Sudoku elements.
   The IDs are assigned block by block:
   - Block 0 → IDs 0..8
   - Block 1 → IDs 9..17
   - Block 2 → IDs 18..26
   - Block 3 → IDs 27..35
   ...
   Inside each block, IDs increase row-wise:
     0 1 2
     3 4 5
     6 7 8
  */

  assert(id >= 0 && id < 81, 'id must be between 0 and 80');

  // Identify which block this ID belongs to
  int block = id ~/ 9; // 0..8
  int inner = id % 9; // position inside block (0..8)

  // Block position (3x3 grid of blocks)
  int blockRow = block ~/ 3; // 0..2
  int blockCol = block % 3; // 0..2

  // Position inside block (3x3)
  int innerRow = inner ~/ 3; // 0..2
  int innerCol = inner % 3; // 0..2

  // Global row/col in the Sudoku grid
  int row = blockRow * 3 + innerRow;
  int col = blockCol * 3 + innerCol;

  assert(row < numColumns && col < numColumns,
      'Computed row/col exceed Sudoku grid!');

  return GridPosition(row, col);
}

int boolToU8(bool value) => value ? 1 : 0;
bool u8ToBool(int value) => value != 0;


// Copyright 2025, Mirko THULKE, Versailles
