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

  DateTime? _eraseAllConfirmedAt;
  bool _eraseAllJustConfirmed = false;

  DateTime? _savedGivensConfirmedAt;
  bool _savedGivensJustConfirmed = false;

  DateTime? _isResetToGivensConfirmedAt;
  bool _isResetToGivensJustConfirmed = false;

  DateTime? _isSelectAllCandConfirmedAt;
  bool _isSelectAllCandJustConfirmed = false;

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
        final isResetToGivens = _selected[addRemoveListIndex.resetToGivens];
        final isSelectAllCand = _selected[addRemoveListIndex.selectAllCand];

        final isDoubleTap = _lastPressed != null &&
            now.difference(_lastPressed!) < const Duration(milliseconds: 500);

        final recentlyErased = _eraseAllConfirmedAt != null &&
            now.difference(_eraseAllConfirmedAt!) < const Duration(seconds: 2);

        final recentlySaved = _savedGivensConfirmedAt != null &&
            now.difference(_savedGivensConfirmedAt!) <
                const Duration(seconds: 2);

        final recentlyResetToGivens = _isResetToGivensConfirmedAt != null &&
            now.difference(_isResetToGivensConfirmedAt!) <
                const Duration(seconds: 2);

        final recentlySelectAllCand = _isSelectAllCandConfirmedAt != null &&
            now.difference(_isSelectAllCandConfirmedAt!) <
                const Duration(seconds: 2);

        // eraseALL Logic
        if (isEraseAll && isDoubleTap && !_eraseAllJustConfirmed) {
          _eraseAllJustConfirmed = true;
          _eraseAllConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 224, 15, 0));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedRemoveList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _eraseAllJustConfirmed = false;
          });
        } else if (isEraseAll && !recentlyErased) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap twice quickly to confirm save / erase"),
            ),
          );
          // SaveGivens Logic
        } else if (isSaveGivens && isDoubleTap && !_savedGivensJustConfirmed) {
          _savedGivensJustConfirmed = true;
          _savedGivensConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedAddList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _savedGivensJustConfirmed = false;
          });
        } else if (isSaveGivens && !recentlySaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap twice quickly to confirm save / erase"),
            ),
          );
        } else if (isResetToGivens &&
            isDoubleTap &&
            !_isResetToGivensJustConfirmed) {
          _isResetToGivensJustConfirmed = true;
          _isResetToGivensConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedAddList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _savedGivensJustConfirmed = false;
          });
        } else if (isResetToGivens && !recentlyResetToGivens) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap twice quickly to confirm reset to givens"),
            ),
          );
        } else if (isSelectAllCand &&
            isDoubleTap &&
            !_isSelectAllCandJustConfirmed) {
          _isSelectAllCandJustConfirmed = true;
          _isSelectAllCandConfirmedAt = DateTime.now();

          setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

          await Provider.of<DataProvider>(context, listen: false)
              .updateDataselectedAddList(_selected);

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _iconColor = Colors.blue[200]);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _isSelectAllCandJustConfirmed = false;
          });
        } else if (isSelectAllCand && !recentlySelectAllCand) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Tap twice quickly to confirm select all candidates"),
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
