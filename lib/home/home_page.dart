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
import 'package:provider/provider.dart';
import 'package:sudoku/utils/export.dart';

////////////////////////////////////////////////////////////
// Homepage screen . This is the overall root screen

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeConfig = context.watch<SizeConfig>();
    sizeConfig.init(context);

    final isLandscape = sizeConfig.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        child: isLandscape
            ? _buildLandscapeLayout(sizeConfig)
            : _buildPortraitLayout(sizeConfig),
      ),
    );
  }

  /// 🟩 Portrait layout — stacked vertically
  Widget _buildPortraitLayout(SizeConfig sizeConfig) {
    return SafeArea(
      child: Column(
        children: [
          // Top HMI bar
          Material(
            elevation: 4,
            color: Colors.red.shade200, // temporary debug color
            shadowColor: Colors.black26,
            child: SizedBox(
              width: double.infinity,
              height: sizeConfig.safeBlockTopHMIGridVertical,
              child: const CustomAppBar(),
            ),
          ),

          // Sudoku grid — square, centered
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final gridSize = sizeConfig.screenWidth < availableHeight
                      ? sizeConfig.screenWidth
                      : availableHeight;

                  return Container(
                    width: gridSize,
                    height: gridSize,
                    color: Colors.green.shade300, // debug color
                    child: const SudokuGrid(),
                  );
                },
              ),
            ),
          ),

          // Bottom HMI bar
          Material(
            elevation: 4,
            color: Colors.blue.shade200, // debug color
            shadowColor: Colors.black26,
            child: SizedBox(
              width: double.infinity,
              height: sizeConfig.safeBlockBottomHMIGridVertical,
              child: const ToggleButtonsSample(),
            ),
          ),
        ],
      ),
    );
  }

  /// 🟦 Landscape layout — mirrors portrait logic (consistent strategy)
  /// 🟦 Landscape layout — grid on the left, buttons stacked vertically on the right
  Widget _buildLandscapeLayout(SizeConfig sizeConfig) {
    const double verticalPadding = 2.0; // your desired padding

    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final paddedHeight =
                      constraints.maxHeight - (verticalPadding * 2);

                  // Compute square size using padded height
                  final gridSize = constraints.maxWidth < paddedHeight
                      ? constraints.maxWidth
                      : paddedHeight;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: verticalPadding),
                    child: SizedBox(
                      width: gridSize,
                      height: gridSize,
                      child: Container(
                        color: Colors.green.shade300, // debug
                        child: const SudokuGrid(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // RIGHT SIDE: unchanged
          SizedBox(
            width: sizeConfig.safeBlockTopHMIGridHorizontal,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  color: Colors.red.shade200,
                  child: SizedBox(
                    height: sizeConfig.safeBlockTopHMIGridVertical,
                    width: double.infinity,
                    child: const CustomAppBar(),
                  ),
                ),
                Material(
                  elevation: 4,
                  color: Colors.blue.shade200,
                  child: SizedBox(
                    height: sizeConfig.safeBlockBottomHMIGridVertical,
                    width: double.infinity,
                    child: const ToggleButtonsSample(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
