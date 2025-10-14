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
import 'package:flutter/material.dart';

import 'package:sudoku/utils/shared_types.dart';

class SudokuSelectorButton extends StatefulWidget {
  const SudokuSelectorButton({super.key});

  @override
  State<SudokuSelectorButton> createState() => _SudokuSelectorButtonState();
}

class _SudokuSelectorButtonState extends State<SudokuSelectorButton> {
  SudokuItem? _selectedSudoku;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SudokuItem>(
      icon: const Icon(Icons.grid_view_rounded),
      initialValue: _selectedSudoku,
      onSelected: (item) => setState(() => _selectedSudoku = item),
      itemBuilder: (context) => const [
        PopupMenuItem(value: SudokuItem.itemOne, child: Text('Sudoku 1')),
        PopupMenuItem(value: SudokuItem.itemTwo, child: Text('Sudoku 2')),
        PopupMenuItem(value: SudokuItem.itemThree, child: Text('Sudoku 3')),
      ],
    );
  }
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.