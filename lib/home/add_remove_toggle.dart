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
