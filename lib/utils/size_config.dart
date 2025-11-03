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
import 'size_config.dart'; // if you put it in another file



class OrientationAwareWidget extends StatefulWidget {
  const OrientationAwareWidget({super.key});

  @override
  State<OrientationAwareWidget> createState() => _OrientationAwareWidgetState();
}


class _OrientationAwareWidgetState extends State<OrientationAwareWidget> {
  late SizeConfig sizeConfig; // ✅ instance of SizeConfig
  String _currentMode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Initialize SizeConfig whenever dependencies (like orientation) change
    sizeConfig = SizeConfig()..init(context);
  }

  void _updateMode(Orientation orientation) {
    setState(() {
      _currentMode = orientation == Orientation.portrait
          ? 'Portrait mode initialized'
          : 'Landscape mode initialized';
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    // Reinitialize when building
    sizeConfig.init(context);

    
  }
}



class SizeConfig {
  late MediaQueryData mediaQueryData;
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

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    orientation = mediaQueryData.orientation; // 👈 Store current orientation

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
    
    // ✅ Delegate calculation based on current orientation
    if (orientation == Orientation.portrait) {
      _calculatePortrait();
    } else {
      _calculateLandscape();
    }
  }

  /// 📱 Portrait-specific calculations
  void _calculatePortrait() {
    // AppBar shall take 20% of the safe vertical screen size
    safeBlockTopHMIGridVertical = safeBlockVertical! * 0.2;

    // Sudokugrid shall extend to the minimum of screen width / height,
    // but not greater than 0.66 of this dimension; to leave enough space for the HMI segment.
    safeBlockMidSudokuGridVertical =
        min(safeBlockVertical! * 0.66, safeBlockHorizontal!);

    // HMI height shall take the remaining space, by using scroling if necessary.
    safeBlockBottomHMIGridVertical = (safeBlockVertical! -
        safeBlockMidSudokuGridVertical! -
        safeBlockTopHMIGridVertical!);

    // For horizontal orientation
    safeBlockTopHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockMidSudokuGridHorizontal =
        safeBlockMidSudokuGridVertical!; // Grid shall be a square.
  }

    /// 🖥️ Landscape-specific calculations
  void _calculateLandscape() {

    // AppBar shall take 20% of the safe vertical screen size
    safeBlockTopHMIGridVertical = safeBlockVertical! * 0.2;

    // Sudokugrid shall extend to the minimum of screen width / height,
    // but not greater than 0.66 of this dimension; to leave enough space for the HMI segment.
    safeBlockMidSudokuGridVertical =
        min(safeBlockVertical! * 0.66, safeBlockHorizontal!);

    // HMI height shall take the remaining space, by using scroling if necessary.
    safeBlockBottomHMIGridVertical = (safeBlockVertical! -
        safeBlockMidSudokuGridVertical! -
        safeBlockTopHMIGridVertical!);

    // For horizontal orientation
    safeBlockTopHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockBottomHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockMidSudokuGridHorizontal =
        safeBlockMidSudokuGridVertical!; // Grid shall be a square.

  }
}



// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.