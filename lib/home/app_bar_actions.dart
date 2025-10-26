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
import 'package:sudoku/utils/export.dart';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fallback height if SizeConfig hasn't initialized yet
    final appBarHeight = SizeConfig.safeBlockTopAppBarGridVertical ?? 56.0;
    final appBarWidth = SizeConfig.safeBlockTopAppBarGridHorizontal ?? 56.0;

    return Material(
      color: Colors.white, // AppBar background
      elevation: 4,
      child: SafeArea(
        bottom: false, // avoids extra bottom padding inside AppBar
        child: SizedBox(
          height: appBarHeight,
          width: appBarWidth,
          // ✅ Center everything horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              TopActionButtons(),
              SizedBox(height: 2),
              AddRemoveToggle(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final double height = (SizeConfig.safeBlockTopAppBarGridVertical != null &&
            SizeConfig.safeBlockTopAppBarGridVertical!.isFinite)
        ? SizeConfig.safeBlockTopAppBarGridVertical!
        : 56.0;

    return Size.fromHeight(height);
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
