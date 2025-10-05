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
