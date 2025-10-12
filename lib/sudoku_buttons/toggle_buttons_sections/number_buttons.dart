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
import 'package:sudoku/utils/export.dart';

class NumberButtons extends StatelessWidget {
  final bool isVertical;
  final List<bool> selectedList;
  final double maxWidth;
  final ValueChanged<List<bool>> onUpdate;

  const NumberButtons({
    super.key,
    required this.isVertical,
    required this.selectedList,
    required this.maxWidth,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      onPressed: (index) {
        final newList =
            List<bool>.generate(selectedList.length, (i) => i == index);
        onUpdate(newList);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.green[700],
      selectedColor: Colors.white,
      fillColor: Colors.green[200],
      color: Colors.green[400],
      constraints: BoxConstraints(
        minHeight: maxWidth * 0.8,
        maxHeight: maxWidth * 0.8,
        minWidth: maxWidth,
        maxWidth: maxWidth,
      ),
      isSelected: selectedList,
      children: SudokuNumber.values
          .map(
            (n) => FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                n.display,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// Copyright 2025, Mirko THULKE, Versailles