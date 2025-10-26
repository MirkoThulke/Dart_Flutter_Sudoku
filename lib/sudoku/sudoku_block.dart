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

class SudokuBlock extends StatelessWidget {
  final int block_id; // Unique ID of the block [0...8]

  const SudokuBlock({super.key, required this.block_id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(0.1), // optional spacing outside the block
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue[
                600]!, //  const Color.fromARGB(255, 107, 77, 243), // border color
            width: 1, // outer line thickness
          ),
        ),
        child: GridView.count(
          primary: true,
          padding: EdgeInsets.zero, // const EdgeInsets.all(1),
          crossAxisSpacing: 0.5,
          mainAxisSpacing: 0.5,
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(), // prevents scrolling
          childAspectRatio: 1.0,
          children: List.generate(9, (i) {
            return SudokuElement(
              element_id: block_id * constSudokuNumRow + i,
            );
          }),
        ),
      ),
    );
  }
}


// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.