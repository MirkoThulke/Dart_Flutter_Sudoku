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

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  static double? safeBlockAppBarGridVertical;
  static double? safeBlockSudokuGridVertical;
  static double? safeBlockHMIGridVertical;

  static double? safeBlockAppBarGridHorizontal;
  static double? safeBlockSudokuGridHorizontal;
  static double? safeBlockHMIGridHorizontal;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth!;
    blockSizeVertical = screenHeight!;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!);
    safeBlockVertical = (screenHeight! - _safeAreaVertical!);

    safeBlockAppBarGridVertical = safeBlockVertical! * 0.2;

// Sudokugrid shall extend to the minimum of screen width / height,
// but not greater than 0.66 of this dimension; to leave enough space for the HMI segment.

    safeBlockSudokuGridVertical =
        min(safeBlockVertical! * 0.66, safeBlockHorizontal!);

// HMI height shall take the remaining space
    safeBlockHMIGridVertical = (safeBlockVertical! -
        safeBlockSudokuGridVertical! -
        safeBlockAppBarGridVertical!);

    safeBlockAppBarGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockSudokuGridHorizontal =
        safeBlockSudokuGridVertical!; // Grid shall be a square.
  }
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.