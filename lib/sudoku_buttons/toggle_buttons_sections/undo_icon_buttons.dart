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

class UndoIconButtons extends StatelessWidget {
  final bool isVertical;
  final List<bool> selectedList;
  final ValueChanged<List<bool>> onUpdate;

  const UndoIconButtons({
    super.key,
    required this.isVertical,
    required this.selectedList,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      onPressed: (index) {
        final newList = List<bool>.from(selectedList);
        for (int i = 0; i < newList.length; i++) {
          newList[i] = i == index;
        }
        onUpdate(newList);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.blue[700],
      selectedColor: Colors.white,
      fillColor: Colors.blue[200],
      color: Colors.blue[400],
      constraints: const BoxConstraints(minHeight: 20.0, minWidth: 80.0),
      isSelected: selectedList,
      children: undoiconlist,
    );
  }
}

// Copyright 2025, Mirko THULKE, Versailles
