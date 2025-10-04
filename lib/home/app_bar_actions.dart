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
  SelectAddRemoveList _selectAddRemoveListNewData = <bool>[true, false];

  DateTime? _lastPressed; // For secure button

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
            onPressed: (int index) {
              final now = DateTime.now();

              // Check if second tap happened within 500ms
              if (_lastPressed != null &&
                  now.difference(_lastPressed!) <
                      const Duration(milliseconds: 500)) {
                // ✅ Perform action only after double-tap
                for (int i = 0; i < _selectAddRemoveListNewData.length; i++) {
                  _selectAddRemoveListNewData[i] = i == index;
                }

                Provider.of<DataProvider>(context, listen: false)
                    .updateDataselectAddRemoveList(_selectAddRemoveListNewData);
              } else {
                // First tap → just warn user
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tap again quickly to confirm")),
                );
              }

              _lastPressed = now;
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            selectedBorderColor: Colors.blue[700],
            selectedColor: Colors.white,
            fillColor: Colors.blue[200],
            color: Colors.blue[400],
            constraints: const BoxConstraints(
              minHeight: 20.0,
              minWidth: 80.0,
            ),
            isSelected: _selectAddRemoveListNewData,
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