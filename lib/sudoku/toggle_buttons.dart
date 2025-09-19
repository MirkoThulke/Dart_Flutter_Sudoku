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
import 'package:provider/provider.dart'; // data excahnge between classes
import 'dart:math'; // basics
import 'package:logging/logging.dart'; // logging

// Import specific dart files
import 'package:sudoku/utils/export.dart';

//////////////////////////////////////////////////////////////////////////
/// HMI / buttons
//////////////////////////////////////////////////////////////////////////

class ToggleButtonsSample extends StatefulWidget {
  const ToggleButtonsSample({super.key});

  @override
  State<ToggleButtonsSample> createState() => _ToggleButtonsSampleState();
}

class _ToggleButtonsSampleState extends State<ToggleButtonsSample> {
///////////////////////////////////////////////////
  /// State HMI variables :
  ///
  // HMI Number selection input

  SelectedNumberList _selectedNumberList =
      List<bool>.from(constSelectedNumberList);

  SelectedSetResetList _selectedSetResetList =
      List<bool>.from(constSelectedSetResetList);

  SelectedPatternList _selectedPatternList =
      List<bool>.from(constSelectedPatternList);

  SelectedUndoIconList _selectedUndoIconList =
      List<bool>.from(constSelectedUndoIconList);

  // variable to calculate max. size of button list
  double selectedNumberListWidthMax = 0.0;
  double selectedSetResetListWidthMax = 0.0;
  double selectedPatternListWidthMax = 0.0;
  double selectedUndoIconListWidthMax = 0.0;

  final bool _vertical = false; // constant setting

// State HMI variables END
///////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Dimension apply to individual buttons, thus must be divided by number of buttons in the array
    selectedNumberListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedNumberList.length);

    selectedSetResetListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedSetResetList.length); // for futur use if required.

    selectedPatternListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedPatternList.length); // for futur use if required.

    selectedUndoIconListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedUndoIconList.length); // for futur use if required.

    Logger.root.level = Level.ALL;
    log.info(
        'selectedNumberListWidthMax: $selectedNumberListWidthMax.toString()');
    log.info(
        'selectedSetResetListWidthMax: $selectedSetResetListWidthMax.toString()');
    log.info(
        'selectedPatternListWidthMax: $selectedPatternListWidthMax.toString()');
    log.info(
        'selectedUndoIconListWidthMax: $selectedUndoIconListWidthMax.toString()');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(), // no scrolling
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ToggleButtons with a single selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedSetResetList.length; i++) {
                      _selectedSetResetList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedSetResetList(_selectedSetResetList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedSetResetList,
                children: setresetlist,
              ),
              // ToggleButtons with a multiple selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    assert(index <= constIntPatternList.user.value,
                        'index exceeds maximum allowed size!');
                    _selectedPatternList[index] = !_selectedPatternList[index];
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedPatternList(_selectedPatternList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedPatternList,
                children: patternlistButtonList,
              ),
              // ToggleButtons with icons only.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedUndoIconList.length; i++) {
                      _selectedUndoIconList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedUndoIconList(_selectedUndoIconList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedUndoIconList,
                children: undoiconlist,
              ),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedNumberList.length; i++) {
                      _selectedNumberList[i] = i == index;
                      // Update data in the provider
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataNumberlist(_selectedNumberList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: BoxConstraints(
                  minHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  maxHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  minWidth: selectedNumberListWidthMax,
                  maxWidth: selectedNumberListWidthMax,
                ),
                isSelected: _selectedNumberList,
                children: constTextNumberlist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Copyright 2025, Mirko THULKE, Versailles