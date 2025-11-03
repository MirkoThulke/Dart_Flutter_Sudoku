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

import 'package:flutter/material.dart'; // basics

// Import specific dart files
import 'package:sudoku/utils/export.dart';

////////////////////////////////////////////////////////////
// Homepage screen . This is the overall root screen
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // obtain current size of App on screen

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: SizeConfig.safeBlockTopHMIGridVertical!,
          // Top bar button list is defined is seperate class
          actions: [CustomAppBar()]),
      // _appBarActions
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Align children vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align children horizontall
        children: [
          Container(
            height: SizeConfig.safeBlockMidSudokuGridVertical!,
            width: SizeConfig.safeBlockMidSudokuGridHorizontal!,
            color: Colors.orange,
            child: const SudokuGrid(),
          ),
          Expanded(
              child: Container(
            height: SizeConfig
                .safeBlockBottomHMIGridVertical!, // what remaines if appbar and sudokugrid is placed
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.blue,
            child: ToggleButtonsSample(),
          ))
        ],
      ),
    );
  }
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.