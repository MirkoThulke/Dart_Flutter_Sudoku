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

import 'package:flutter/material.dart'; // basics

// Import specific dart files
import 'package:sudoku/utils/export.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(0.1),
        crossAxisSpacing: 0.1,
        mainAxisSpacing: 0.1,
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


// Copyright 2025, Mirko THULKE, Versailles