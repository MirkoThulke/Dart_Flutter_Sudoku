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

import 'package:sudoku/utils/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

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

  final bool _vertical = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // Total HMI area height
    final double appHmiHeightTotal =
        SizeConfig.safeBlockHMIGridVertical ?? 180.0;

    // Spacing between rows
    final double topSpacing = max((appHmiHeightTotal * 0.15), 12.0);
    final double spacing = max((appHmiHeightTotal * 0.1), 8.0);
    final double bottomSpacing = max((appHmiHeightTotal * 0.2), 16.0);

    // Number of rows
    const int rowCount = 3;

    // Calculate each row's height, accounting for spacing
    final double rowHeightAdjusted = (appHmiHeightTotal -
            spacing * (rowCount - 1) -
            bottomSpacing -
            topSpacing) /
        rowCount;

    // Max width per number button
    final double selectedNumberListWidthMax =
        (SizeConfig.safeBlockHorizontal ?? 400.0) *
            0.9 /
            max(1, _selectedNumberList.length);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: topSpacing),
              // Set / Reset Buttons
              SizedBox(
                width: double.infinity, // full width to allow centering
                height: rowHeightAdjusted,
                child: Center(
                  child: SetResetButtons(
                    isVertical: _vertical,
                    selectedList: _selectedSetResetList,
                    onUpdate: (list) {
                      setState(() => _selectedSetResetList = list);
                      Provider.of<DataProvider>(context, listen: false)
                          .updateDataselectedSetResetList(list);
                    },
                  ),
                ),
              ),

              SizedBox(height: spacing),

              // Number Buttons
              SizedBox(
                width: double.infinity, // full width to allow centering
                height: rowHeightAdjusted,
                child: Center(
                  child: NumberButtons(
                    isVertical: _vertical,
                    selectedList: _selectedNumberList,
                    maxWidth: selectedNumberListWidthMax,
                    onUpdate: (list) {
                      setState(() => _selectedNumberList = list);
                      Provider.of<DataProvider>(context, listen: false)
                          .updateDataNumberlist(list);
                    },
                  ),
                ),
              ),

              SizedBox(height: spacing),

              // Pattern Buttons
              SizedBox(
                width: double.infinity, // full width to allow centering
                height: rowHeightAdjusted,
                child: Center(
                  child: PatternButtons(
                    isVertical: _vertical,
                    selectedList: _selectedPatternList,
                    onUpdate: (list) {
                      setState(() => _selectedPatternList = list);
                      Provider.of<DataProvider>(context, listen: false)
                          .updateDataselectedPatternList(list);
                    },
                  ),
                ),
              ),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.