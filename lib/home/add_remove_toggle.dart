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

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class AddRemoveToggle extends StatefulWidget {
  const AddRemoveToggle({super.key});

  @override
  State<AddRemoveToggle> createState() => _AddRemoveToggleState();
}

class _AddRemoveToggleState extends State<AddRemoveToggle> {
  SelectedAddRemoveList _selected = <bool>[true, false, false, false];
  DateTime? _lastPressed;
  DateTime? _eraseConfirmedAt;
  bool _eraseJustConfirmed = false;
  DateTime? _savedConfirmedAt;
  bool _savedJustConfirmed = false;
  Color? _iconColor = Colors.blue[200];

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (index) async {
        final now = DateTime.now();

        setState(() {
          for (int i = 0; i < _selected.length; i++) {
            _selected[i] = i == index;
          }
        });

        final isEraseAll = _selected[addRemoveListIndex.eraseAll];
        final isSaveGivens = _selected[addRemoveListIndex.saveGivens];

        final isDoubleTap = _lastPressed != null &&
            now.difference(_lastPressed!) < const Duration(milliseconds: 500);

        final recentlyErased = _eraseConfirmedAt != null &&
            now.difference(_eraseConfirmedAt!) < const Duration(seconds: 2);
        final recentlySaved = _savedConfirmedAt != null &&
            now.difference(_savedConfirmedAt!) < const Duration(seconds: 2);

        if (isEraseAll && isDoubleTap && !_eraseJustConfirmed) {
          _eraseJustConfirmed = true;
          _eraseConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 224, 15, 0));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedRemoveList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _eraseJustConfirmed = false;
          });
        } else if (isEraseAll && !recentlyErased) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap twice quickly to confirm save / erase"),
            ),
          );
        } else if (isSaveGivens && isDoubleTap && !_savedJustConfirmed) {
          _savedJustConfirmed = true;
          _savedConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedAddList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _savedJustConfirmed = false;
          });
        } else if (isSaveGivens && !recentlySaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap twice quickly to confirm save / erase"),
            ),
          );
        }

        _lastPressed = now;
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.blue[700],
      selectedColor: Colors.white,
      constraints: const BoxConstraints(minHeight: 30.0, minWidth: 80.0),
      fillColor: _iconColor,
      color: Colors.blue[400],
      isSelected: _selected,
      children: addRemoveList,
    );
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
