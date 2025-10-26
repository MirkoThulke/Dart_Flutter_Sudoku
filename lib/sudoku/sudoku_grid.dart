/* 
##############################################################################

Author: MIRKO THULKE
Copyright (c) 2025, MIRKO THULKE
All rights reserved.

Date: 2025, VERSAILLES, FRANCE

License: "All Rights Reserved – View Only"

Permission is hereby granted to view and share this code in its original,
unmodified form for educational or reference purposes only.

Any other use, including but not limited to copying, modification,
redistribution, commercial use, or inclusion in other projects, is strictly
prohibited without the express written permission of the author.

The Software is provided "AS IS", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose, and noninfringement. In no event shall the
author be liable for any claim, damages, or other liability arising from the
use of the Software.

Contact: MIRKO THULKE (for permission requests)

##############################################################################
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


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.