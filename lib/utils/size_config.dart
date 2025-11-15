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

// Import specific dart files

import 'package:flutter/material.dart'; // basics
import 'dart:math'; // basics

/////////////////////////////////////
// Use this class to handle the overall dimension of the app content depending on the actual screen size

/*
------------------------------------------------------------------
safeBlockTopHMIdVertical: 
20% of the safe vertical screen size

------------------------------------------------------------------
safeBlockSudokuGridVertical: 
min(66% of the safe vertical screen size, 100% of the safe horizontal screen size)




------------------------------------------------------------------
safeBlockBottomHMIVertical: 
remaining vertical space after allocating space for AppBar and SudokuGrid



------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'dart:math';

class SizeConfig extends ChangeNotifier {
  MediaQueryData _mediaQueryData = const MediaQueryData(); // default safe value
  Orientation orientation = Orientation.portrait; // safe default

  double screenWidth = 0;
  double screenHeight = 0;
  double blockSizeHorizontal = 0;
  double blockSizeVertical = 0;

  double safeAreaHorizontal = 0;
  double safeAreaVertical = 0;
  double safeBlockHorizontal = 0;
  double safeBlockVertical = 0;

  double safeBlockTopHMIGridVertical = 0;
  double safeBlockMidSudokuGridVertical = 0;
  double safeBlockBottomHMIGridVertical = 0;

  double safeBlockTopHMIGridHorizontal = 0;
  double safeBlockMidSudokuGridHorizontal = 0;
  double safeBlockBottomHMIGridHorizontal = 0;

  /// ✅ Initialize and notify listeners if orientation or size changes
  void init(BuildContext context) {
    final newMediaQuery = MediaQuery.of(context);
    final newOrientation = newMediaQuery.orientation;

    // Detect if anything changed
    final sizeChanged = screenWidth != newMediaQuery.size.width ||
        screenHeight != newMediaQuery.size.height ||
        orientation != newOrientation;

    _mediaQueryData = newMediaQuery;
    orientation = newOrientation;

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = screenWidth - safeAreaHorizontal;
    safeBlockVertical = screenHeight - safeAreaVertical;

    // Recalculate layout blocks based on orientation
    if (orientation == Orientation.portrait) {
      _calculatePortrait();
    } else {
      _calculateLandscape();
    }

    _validateLayout(); // ✅ call the check

    // ✅ Only notify listeners if something actually changed
    if (sizeChanged) {
      notifyListeners();
    }
  }

  void _calculatePortrait() {
    final topRatio = 0.25;
    final bottomRatio = 0.25;

    safeBlockTopHMIGridVertical = safeBlockVertical * topRatio;
    safeBlockTopHMIGridHorizontal = double.infinity;

    safeBlockBottomHMIGridVertical = safeBlockVertical * bottomRatio;
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal;

    safeBlockMidSudokuGridVertical = min(
        safeBlockHorizontal,
        safeBlockVertical -
            safeBlockTopHMIGridVertical -
            safeBlockBottomHMIGridVertical);
    safeBlockMidSudokuGridHorizontal = safeBlockHorizontal;
  }

  void _calculateLandscape() {
    final leftRatio = 0.25;
    final rightRatio = 0.25;

    safeBlockTopHMIGridVertical = safeBlockVertical;
    safeBlockTopHMIGridHorizontal = safeBlockHorizontal * leftRatio;

    safeBlockBottomHMIGridVertical = safeBlockVertical;
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal * rightRatio;

    safeBlockMidSudokuGridVertical = safeBlockVertical;
    safeBlockMidSudokuGridHorizontal = min(
        safeBlockVertical,
        safeBlockHorizontal -
            safeBlockTopHMIGridHorizontal -
            safeBlockBottomHMIGridHorizontal);
  }

  /// Private method to assert HMI layout fits screen
  void _validateLayout() {
    if (orientation == Orientation.portrait) {
      assert(
        safeBlockTopHMIGridVertical +
                safeBlockMidSudokuGridVertical +
                safeBlockBottomHMIGridVertical <=
            screenHeight,
        'Portrait HMI blocks exceed screen height!',
      );
    } else {
      assert(
        safeBlockTopHMIGridHorizontal +
                safeBlockMidSudokuGridHorizontal +
                safeBlockBottomHMIGridHorizontal <=
            screenWidth,
        'Landscape HMI blocks exceed screen width!',
      );
    }
  }
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.