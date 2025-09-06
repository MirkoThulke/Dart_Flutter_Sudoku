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

typedef SelectedNumberList = List<bool>;
typedef SelectedSetResetList = List<bool>;
typedef SelectedPatternList = List<bool>;
typedef SelectedUndoIconList = List<bool>;
typedef SelectAddRemoveList = List<bool>;

/////////////////////////////////////
// constants
/////////////////////////////////////

// Hardcoded sizes of above types
const int constSelectedNumberListSize = 9;
const int constSelectedSetResetListSize = 4;
const int constSelectedPatternListSize = 5;
const int constSelectedUndoIconListSize = 2;
const int constSelectAddRemoveListSize = 2;

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

const List<bool> constSelectedSetResetList = [true, false, false, false];

const List<bool> constSelectedPatternList = [true, false, false, false, false];

const List<bool> constSelectedUndoIconList = [false, false];

const List<bool> constSelectAddRemoveList = [false, false];

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

const List<Widget> patternlist = <Widget>[
  Text('HiLightOn'),
  Text('AI'),
  Text('Pairs'),
  Text('MatchPairs'),
  Text('Twins'),
];

const List<Widget> undoiconlist = <Widget>[
  Icon(Icons.undo),
  Icon(Icons.redo),
];

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

const List<Widget> addRemoveList = <Widget>[
  Icon(Icons.add_box_outlined),
  Icon(Icons.remove_circle_outline),
];

// This is the type used by the popup menu below.
enum SudokuItem { itemOne, itemTwo, itemThree }

// This is the type used by the popup menu below.
enum SampleItem { itemOne, itemTwo, itemThree }
/////////////////////////////////////
