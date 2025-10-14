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

class PatternButtons extends StatelessWidget {
  final bool isVertical;
  final List<bool> selectedList;
  final ValueChanged<List<bool>> onUpdate;

  const PatternButtons({
    super.key,
    required this.isVertical,
    required this.selectedList,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      onPressed: (index) {
        final newList = List<bool>.from(selectedList);
        newList[index] = !newList[index];
        onUpdate(newList);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.green[700],
      selectedColor: Colors.white,
      fillColor: Colors.green[200],
      color: Colors.green[400],
      constraints: const BoxConstraints(minHeight: 30.0, minWidth: 75.0),
      isSelected: selectedList,
      children: patternlistButtonList,
    );
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
