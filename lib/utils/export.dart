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

/*
List of all required .dart files for conveniend import.
'Package' avoids absolute path.
example of usage : 
import 'package:sudoku/utils/export.dart';
*/

// Global type definitions, enum and constants
export 'package:sudoku/utils/shared_types.dart';

// RUST FFI backend Interface
export 'package:sudoku/rust_ffi/rust_matrix.dart';

// HMI Size Config Class
export 'package:sudoku/utils/size_config.dart';

// Logging class
export 'package:sudoku/utils/sudoku_logging.dart';

// DataProvider class
export 'package:sudoku/providers/data_provider.dart';

// DataProvider class
export 'package:sudoku/app.dart';

// homepage
export 'package:sudoku/home/home_page.dart';

// App top bar hmi
export 'package:sudoku/home/app_bar_actions.dart';

// Sudoku Gridd widget
export 'package:sudoku/sudoku/sudoku_grid.dart';

// Sudoku Gridd widget
export 'package:sudoku/sudoku/sudoku_block.dart';

// Sudoku element widget
export 'package:sudoku/sudoku/sudoku_element.dart';

// Sudoku element widget
export 'package:sudoku/sudoku_buttons/toggle_buttons.dart';



// Copyright 2025, Mirko THULKE, Versailles