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

// Import specific dart files
import 'package:sudoku/utils/export.dart';
import 'package:sudoku/home/app_bar_actions.dart';

////////////////////////////////////////////////////////////
// Homepage screen . This is the overall root screen
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // obtain current size of App on screen

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: SizeConfig.safeBlockAppBarGridVertical!, // 5 percent
          title: const Text('Tulli Sudoku'),
          // Top bar button list is defined is seperate class
          actions: [AppBarActions()]),
      // _appBarActions
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Align children vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align children horizontall
        children: [
          Container(
            height: SizeConfig.safeBlockSudokuGridVertical!,
            width: SizeConfig.safeBlockSudokuGridHorizontal!,
            color: Colors.orange,
            child: const SudokuGrid(),
          ),
          Expanded(
              child: Container(
            height: SizeConfig
                .safeBlockHMIGridVertical!, // what remaines if appbar and sudokugrid is placed
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.blue,
            child: ToggleButtonsSample(),
          ))
        ],
      ),
    );
  }
}


// Copyright 2025, Mirko THULKE, Versailles