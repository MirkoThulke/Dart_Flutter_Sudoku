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
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:logging/logging.dart';

import 'package:sudoku/utils/export.dart';
import 'toggle_buttons_sections/set_reset_buttons.dart';
import 'toggle_buttons_sections/pattern_buttons.dart';
//import 'toggle_buttons_sections/undo_icon_buttons.dart';
import 'toggle_buttons_sections/number_buttons.dart';

class ToggleButtonsSample extends StatefulWidget {
  const ToggleButtonsSample({super.key});

  @override
  State<ToggleButtonsSample> createState() => _ToggleButtonsSampleState();
}

class _ToggleButtonsSampleState extends State<ToggleButtonsSample> {
  SelectedNumberList _selectedNumberList =
      List<bool>.from(constSelectedNumberList);
  SelectedSetResetList _selectedSetResetList =
      List<bool>.from(constSelectedSetResetList);
  SelectedPatternList _selectedPatternList =
      List<bool>.from(constSelectedPatternList);
  SelectedUndoIconList _selectedUndoIconList =
      List<bool>.from(constSelectedUndoIconList);

  double selectedNumberListWidthMax = 0.0;
  final bool _vertical = false;

  @override
  Widget build(BuildContext context) {
    selectedNumberListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedNumberList.length);
    Logger.root.level = Level.ALL;
    log.info('selectedNumberListWidthMax: $selectedNumberListWidthMax');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              SetResetButtons(
                isVertical: _vertical,
                selectedList: _selectedSetResetList,
                onUpdate: (list) {
                  setState(() => _selectedSetResetList = list);
                  Provider.of<DataProvider>(context, listen: false)
                      .updateDataselectedSetResetList(list);
                },
              ),
              /* const SizedBox(height: 5),
              UndoIconButtons(
                isVertical: _vertical,
                selectedList: _selectedUndoIconList,
                onUpdate: (list) {
                  setState(() => _selectedUndoIconList = list);
                  Provider.of<DataProvider>(context, listen: false)
                      .updateDataselectedUndoIconList(list);
                },
              ),*/
              const SizedBox(height: 40),
              NumberButtons(
                isVertical: _vertical,
                selectedList: _selectedNumberList,
                maxWidth: selectedNumberListWidthMax,
                onUpdate: (list) {
                  setState(() => _selectedNumberList = list);
                  Provider.of<DataProvider>(context, listen: false)
                      .updateDataNumberlist(list);
                },
              ),
              const SizedBox(height: 40),
              PatternButtons(
                isVertical: _vertical,
                selectedList: _selectedPatternList,
                onUpdate: (list) {
                  setState(() => _selectedPatternList = list);
                  Provider.of<DataProvider>(context, listen: false)
                      .updateDataselectedPatternList(list);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Copyright 2025, Mirko THULKE, Versailles