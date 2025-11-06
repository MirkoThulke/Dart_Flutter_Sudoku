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
  late MediaQueryData _mediaQueryData;
  late Orientation orientation;

  late double screenWidth;
  late double screenHeight;
  late double blockSizeHorizontal;
  late double blockSizeVertical;

  late double safeAreaHorizontal;
  late double safeAreaVertical;
  late double safeBlockHorizontal;
  late double safeBlockVertical;

  late double safeBlockTopHMIGridVertical;
  late double safeBlockMidSudokuGridVertical;
  late double safeBlockBottomHMIGridVertical;

  late double safeBlockTopHMIGridHorizontal;
  late double safeBlockMidSudokuGridHorizontal;
  late double safeBlockBottomHMIGridHorizontal;

  /// ✅ Initialize and notify listeners if orientation changes
  void init(BuildContext context) {
    final newMediaQuery = MediaQuery.of(context);
    final newOrientation = newMediaQuery.orientation;

    _mediaQueryData = newMediaQuery;
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = screenWidth - safeAreaHorizontal;
    safeBlockVertical = screenHeight - safeAreaVertical;

    if (orientation != newOrientation) {
      orientation = newOrientation;

      // Recalculate layout blocks
      if (orientation == Orientation.portrait) {
        _calculatePortrait();
      } else {
        _calculateLandscape();
      }

      // ✅ Notify listeners about the change
      notifyListeners();
    }
  }

  void _calculatePortrait() {
    safeBlockTopHMIGridVertical = safeBlockVertical * 0.2;
    safeBlockMidSudokuGridVertical =
        min(safeBlockVertical * 0.66, safeBlockHorizontal);
    safeBlockBottomHMIGridVertical = safeBlockVertical -
        safeBlockMidSudokuGridVertical -
        safeBlockTopHMIGridVertical;

    safeBlockTopHMIGridHorizontal = safeBlockHorizontal;
    safeBlockMidSudokuGridHorizontal = safeBlockMidSudokuGridVertical;
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal;
  }

  void _calculateLandscape() {
    safeBlockTopHMIGridVertical = safeBlockVertical * 0.2;
    safeBlockMidSudokuGridVertical =
        min(safeBlockVertical * 0.66, safeBlockHorizontal);
    safeBlockBottomHMIGridVertical = safeBlockVertical -
        safeBlockMidSudokuGridVertical -
        safeBlockTopHMIGridVertical;

    safeBlockTopHMIGridHorizontal = safeBlockHorizontal;
    safeBlockMidSudokuGridHorizontal = safeBlockMidSudokuGridVertical;
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal;
  }
}



// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.