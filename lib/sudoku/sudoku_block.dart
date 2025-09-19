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

// Import specific dart files
import 'package:sudoku/utils/export.dart';

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
