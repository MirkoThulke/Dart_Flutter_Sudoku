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

import 'package:flutter/material.dart'; // basics
import 'package:provider/provider.dart'; // data excahnge between classes

////// JAVA 1.19 used

////////////////////////////////////////////////////////////
// Main classe  -> root
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()), // your app logic
        ChangeNotifierProvider(create: (_) => SizeConfig()),   // layout + orientation
      ],
      child: MyApp(),
    ),
  );


}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
