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

// Import specific dart files
import 'package:sudoku/utils/export.dart';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fallback height if SizeConfig hasn't initialized yet
    final appBarHeight = SizeConfig.safeBlockAppBarGridVertical ?? 56.0;
    final appBarWidth = SizeConfig.safeBlockAppBarGridHorizontal ?? 56.0;

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
              SizedBox(height: 4),
              AddRemoveToggle(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final double height = (SizeConfig.safeBlockAppBarGridVertical != null &&
            SizeConfig.safeBlockAppBarGridVertical!.isFinite)
        ? SizeConfig.safeBlockAppBarGridVertical!
        : 56.0;

    return Size.fromHeight(height);
  }
}
