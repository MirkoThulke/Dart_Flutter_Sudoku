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

import 'package:flutter/material.dart'; // basics
import 'package:provider/provider.dart'; // data excahnge between classes

////// JAVA 1.19 used

/*
Important Flutter commands:

cmd> flutter run --profile --verbose // extended debug mode
command paletet> Open DevTools  // open the devtools browser
cmd> flutter upgrade
cmd> flutter pub upgrade 
cmd> flutter pub outdated
cmd> flutter build apk
cmd> flutter build apk --debug
cmd> flutter pub get
cmd> flutter clean
cmd> flutter analyse 
cmd> flutter clean build --refresh-dependencis
cmd> gradlew clean
cmd> gradlew cleanBuildCache
cmd> gradlew build
cmd> gradlew build --refresh-dependencies
cmd> flutter pub add "Dart package name"
cmd> flutter devices
cmd> flutter emulators
*/

////////////////////////////////////////////////////////////
// Main classe  -> root
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: MyApp(),
    ),
  );
}

// Copyright 2025, Mirko THULKE, Versailles
