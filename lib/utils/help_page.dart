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

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class HelpPage extends StatelessWidget {
  final String markdownData = """
# 🧩 Sudoku Help

This application is designed to help you solve Sudoku puzzles with visual ease.
The application is not generating puzzles but assists you in solving them by highlighting key features.
It also does not allow to revert back to previous states, in order to keep the focus on solving the puzzle at hand.
The application is intended for preparation to Sudoku competitions, hence the streamlined feature set.
You can call it 'Anti-cheat' Sudoku Solver 😄.

## 🔍 Features
Below are explanations of the main features available in the app.

**Mark Num** — Highlights all occurrences of the selected number.  
**Pairs** — Shows cells with only two remaining possible candidates (Naked/Hidden Pairs).  
**Singles** — Shows cells with only one remaining candidate.  
**Givens** — Displays the original numbers of the puzzle.

---

### 💡 Tips
- Tap a number to highlight it across the grid.  
- Use **Mark Num** to quickly spot conflicts or repetitions.  
- Toggle features on/off to explore solving strategies.
""";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Sudoku Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MarkdownWidget(
                data: markdownData,
                config: MarkdownConfig(
                  configs: [
                    // paragraph uses `textStyle`
                    PConfig(textStyle: const TextStyle(fontSize: 14)),
                    // headings use `style`
                    H1Config(
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    H2Config(
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    H3Config(
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
