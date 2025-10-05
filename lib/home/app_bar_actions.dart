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

import 'package:flutter/material.dart'; // basics
import 'package:provider/provider.dart'; // data excahnge between classes
// Import specific dart files
import 'package:sudoku/utils/export.dart';

//////////////////////////////////////////////////////////////////////////
/// App top bar
//////////////////////////////////////////////////////////////////////////
class appBarActions extends StatefulWidget {
  const appBarActions({super.key});

  @override
  State<appBarActions> createState() => _appBarActions();
}

// A button with a confirmation dialog
class SecureButton extends StatefulWidget {
  final VoidCallback onConfirmed;

  const SecureButton({super.key, required this.onConfirmed});

  @override
  State<SecureButton> createState() => _SecureButtonState();
}

class _SecureButtonState extends State<SecureButton> {
  DateTime? _lastPressed;

  void _handlePress() {
    final now = DateTime.now();

    if (_lastPressed != null &&
        now.difference(_lastPressed!) < const Duration(milliseconds: 500)) {
      // ✅ Second tap within 500ms → trigger secure action
      widget.onConfirmed();
    } else {
      // First tap → just record the time
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap again quickly to confirm")),
      );
    }

    _lastPressed = now;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handlePress,
      child: const Text("Secure Action"),
    );
  }
}
// End of secure button

class _appBarActions extends State<appBarActions> {
  SelectedAddRemoveList _selectedAddRemoveListNewData = <bool>[true, false];

  DateTime? _lastPressed; // For secure button
  Color? _iconBackgroundColorAddRemove = Colors.blue[200]; // initial color
  bool _eraseJustConfirmed = false; // 👈 add this at class level
  DateTime? _eraseConfirmedAt;

  @override
  Widget build(BuildContext context) {
    SudokuItem? _selectedSudoku;

    SampleItem? selectedItem;
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PopupMenuButton<SudokuItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: _selectedSudoku,
              onSelected: (SudokuItem _sudokuItem) {
                setState(() {
                  _selectedSudoku = _sudokuItem;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SudokuItem>>[
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemOne, child: Text('Sudoku 1')),
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemTwo, child: Text('Sudoku 2')),
                    const PopupMenuItem<SudokuItem>(
                        value: SudokuItem.itemThree, child: Text('Sudoku 3')),
                  ]),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) async {
              final now = DateTime.now();

              setState(() {
                for (int i = 0; i < _selectedAddRemoveListNewData.length; i++) {
                  _selectedAddRemoveListNewData[i] = i == index;
                }
              });

              final isRemoveSelected =
                  _selectedAddRemoveListNewData[addRemoveListIndex.remove];
              final isDoubleTap = _lastPressed != null &&
                  now.difference(_lastPressed!) <
                      const Duration(milliseconds: 500);

              // 👇 prevent showing snackbar again within 2 seconds of erase
              final recentlyErased = _eraseConfirmedAt != null &&
                  now.difference(_eraseConfirmedAt!) <
                      const Duration(seconds: 2);

              if (isRemoveSelected && isDoubleTap && !_eraseJustConfirmed) {
                _eraseJustConfirmed = true;
                _eraseConfirmedAt = DateTime.now();

                // Flash red
                setState(() {
                  _iconBackgroundColorAddRemove =
                      const Color.fromARGB(255, 224, 15, 0);
                });

                // Perform erase via Provider Class
                await Provider.of<DataProvider>(context, listen: false)
                    .updateDataselectedAddRemoveList(
                        _selectedAddRemoveListNewData);

                // Reset to blue after 1 second (but keep cooldown)
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _iconBackgroundColorAddRemove = Colors.blue[200];
                    });
                  }
                });

                // Reset erase flag after cooldown (2s total)
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    _eraseJustConfirmed = false;
                  }
                });
              } else if (isRemoveSelected && !recentlyErased) {
                // Show snackbar only if not recently erased
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
            fillColor: _iconBackgroundColorAddRemove,
            color: Colors.blue[400],
            constraints: const BoxConstraints(
              minHeight: 20.0,
              minWidth: 80.0,
            ),
            isSelected: _selectedAddRemoveListNewData,
            children: addRemoveList,
          ),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
          PopupMenuButton<SampleItem>(
              icon: Icon(Icons.list_alt_rounded),
              initialValue: selectedItem,
              onSelected: (SampleItem item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne, child: Text('Item 1')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo, child: Text('Item 2')),
                    const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemThree, child: Text('Item 3')),
                  ]),
        ]);
  }
}


// Copyright 2025, Mirko THULKE, Versailles