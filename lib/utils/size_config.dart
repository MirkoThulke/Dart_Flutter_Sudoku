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

/////////////////////////////////////
// Use this class to handle the overall dimension of the app content depending on the actual screen size

// Import specific dart files
import 'package:sudoku/utils/export.dart';

import 'package:flutter/material.dart'; // basics
import 'dart:math'; // basics
import 'package:logging/logging.dart'; // logging

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

// Button min / max sizes :
    Logger.root.level = Level.ALL;

    log.info(
        'Horizontal size of screen in pixel: $SizeConfig.blockSizeHorizontal.toString()');
    log.info(
        'Vertical size of screen in pixel: $SizeConfig.blockSizeVertical.toString()');
    log.info(
        'Horizontal safe size of screen in pixel: $SizeConfig.safeBlockHorizontal.toString()');
    log.info(
        'Vertical safe size of screen in pixel: $SizeConfig.safeBlockVertical.toString()');
    log.info('AppBar height in pixel: $safeBlockAppBarGridVertical.toString()');
    log.info('Sudoku height in pixel: $safeBlockSudokuGridVertical.toString()');
    log.info('HMI height in pixel: $safeBlockHMIGridVertical.toString()');
  }
}


// Copyright 2025, Mirko THULKE, Versailles