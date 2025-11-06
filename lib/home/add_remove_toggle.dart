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
  List<bool> _selected = [true, false, false, false];
  DateTime? _lastPressed;

  DateTime? _eraseAllConfirmedAt;
  bool _eraseAllJustConfirmed = false;

  DateTime? _savedGivensConfirmedAt;
  bool _savedGivensJustConfirmed = false;

  DateTime? _isResetToGivensConfirmedAt;
  bool _isResetToGivensJustConfirmed = false;

  DateTime? _isSelectAllCandConfirmedAt;
  bool _isSelectAllCandJustConfirmed = false;

  Color _iconColor = Colors.blue[200]!;

  @override
  Widget build(BuildContext context) {
    final sizeConfig = Provider.of<SizeConfig>(context);
    sizeConfig.init(context); // if your class has an init method

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // add left & right padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: buildElevatedToggle(addRemoveListIndex.saveGivens)),
              const SizedBox(width: 4),
              Expanded(
                  child: buildElevatedToggle(addRemoveListIndex.resetToGivens)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                  child: buildElevatedToggle(addRemoveListIndex.selectAllCand)),
              const SizedBox(width: 4),
              Expanded(child: buildElevatedToggle(addRemoveListIndex.eraseAll)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildElevatedToggle(int index) {
    final selected = _selected[index];

    // Child content: icon/image above text
    Widget childContent;
    switch (index) {
      case addRemoveListIndex.saveGivens:
        // First button: custom image
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 4.0), // uniform space between icon and text
              child: Icon(
                Icons.save,
                size: 28,
                color: selected ? Colors.white : Colors.blue[400],
              ),
            ),
            Text(
              addRemoveLabels[addRemoveListIndex.saveGivens],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.white : Colors.blue[400],
              ),
            ),
          ],
        );
        break;
      case addRemoveListIndex.selectAllCand:
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 4.0), // uniform space between icon and text
              child: Icon(
                Icons.checklist,
                size: 28,
                color: selected ? Colors.white : Colors.blue[400],
              ),
            ),
            Text(
              addRemoveLabels[addRemoveListIndex.selectAllCand],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : Colors.blue[400]),
            ),
          ],
        );
        break;
      case addRemoveListIndex.resetToGivens:
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 4.0), // uniform space between icon and text
              child: Icon(
                Icons.refresh,
                size: 28,
                color: selected ? Colors.white : Colors.blue[400],
              ),
            ),
            Text(
              addRemoveLabels[addRemoveListIndex.resetToGivens],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : Colors.blue[400]),
            ),
          ],
        );
        break;
      case addRemoveListIndex.eraseAll:
      default:
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 4.0), // uniform space between icon and text
              child: Icon(
                Icons.delete,
                size: 28,
                color: selected ? Colors.white : Colors.blue[400],
              ),
            ),
            Text(
              addRemoveLabels[addRemoveListIndex.eraseAll],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : Colors.blue[400]),
            ),
          ],
        );
    }

    return ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();

        // Update selection
        setState(() {
          for (int i = 0; i < _selected.length; i++) {
            _selected[i] = i == index;
          }
        });

        final isDoubleTap = _lastPressed != null &&
            now.difference(_lastPressed!) < const Duration(milliseconds: 500);

        _lastPressed = now;

        // Handle button logic
        if (index == addRemoveListIndex.eraseAll) {
          await _handleEraseAll(isDoubleTap);
        } else if (index == addRemoveListIndex.saveGivens) {
          await _handleSaveGivens(isDoubleTap);
        } else if (index == addRemoveListIndex.resetToGivens) {
          await _handleResetToGivens(isDoubleTap);
        } else if (index == addRemoveListIndex.selectAllCand) {
          await _handleSelectAllCand(isDoubleTap);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? _iconColor : Colors.white,
        foregroundColor: Colors.blue[400],
        side: BorderSide(color: Colors.blue[400]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        elevation: selected ? 4 : 0,
      ),
      child: childContent,
    );
  }

  // --- Button Logic Methods ---
  Future<void> _handleEraseAll(bool isDoubleTap) async {
    final now = DateTime.now();
    final recently = _eraseAllConfirmedAt != null &&
        now.difference(_eraseAllConfirmedAt!) < const Duration(seconds: 2);

    if (isDoubleTap && !_eraseAllJustConfirmed) {
      _eraseAllJustConfirmed = true;
      _eraseAllConfirmedAt = DateTime.now();
      setState(() => _iconColor = const Color.fromARGB(255, 224, 15, 0));

      await Provider.of<DataProvider>(context, listen: false)
          .updateDataselectedEraseAll(_selected);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _iconColor = Colors.blue[200]!);
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _eraseAllJustConfirmed = false;
      });
    } else if (!recently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap twice quickly to confirm erase")),
      );
    }
  }

  Future<void> _handleSaveGivens(bool isDoubleTap) async {
    final now = DateTime.now();
    final recently = _savedGivensConfirmedAt != null &&
        now.difference(_savedGivensConfirmedAt!) < const Duration(seconds: 2);

    if (isDoubleTap && !_savedGivensJustConfirmed) {
      _savedGivensJustConfirmed = true;
      _savedGivensConfirmedAt = DateTime.now();
      setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

      await Provider.of<DataProvider>(context, listen: false)
          .updateDataselectedwriteGivensToRust(_selected);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _iconColor = Colors.blue[200]!);
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _savedGivensJustConfirmed = false;
      });
    } else if (!recently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap twice quickly to confirm save")),
      );
    }
  }

  Future<void> _handleResetToGivens(bool isDoubleTap) async {
    final now = DateTime.now();
    final recently = _isResetToGivensConfirmedAt != null &&
        now.difference(_isResetToGivensConfirmedAt!) <
            const Duration(seconds: 2);

    if (isDoubleTap && !_isResetToGivensJustConfirmed) {
      _isResetToGivensJustConfirmed = true;
      _isResetToGivensConfirmedAt = DateTime.now();
      setState(() => _iconColor = const Color.fromARGB(255, 224, 15, 0));

      await Provider.of<DataProvider>(context, listen: false)
          .updateDataselectedResetToGivens(_selected);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _iconColor = Colors.blue[200]!);
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _isResetToGivensJustConfirmed = false;
      });
    } else if (!recently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap twice quickly to confirm reset")),
      );
    }
  }

  Future<void> _handleSelectAllCand(bool isDoubleTap) async {
    final now = DateTime.now();
    final recently = _isSelectAllCandConfirmedAt != null &&
        now.difference(_isSelectAllCandConfirmedAt!) <
            const Duration(seconds: 2);

    if (isDoubleTap && !_isSelectAllCandJustConfirmed) {
      _isSelectAllCandJustConfirmed = true;
      _isSelectAllCandConfirmedAt = DateTime.now();
      setState(() => _iconColor = const Color.fromARGB(255, 0, 224, 15));

      await Provider.of<DataProvider>(context, listen: false)
          .updateDataselectedSetAllCandidates(_selected);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _iconColor = Colors.blue[200]!);
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _isSelectAllCandJustConfirmed = false;
      });
    } else if (!recently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Tap twice quickly to confirm select all candidates")),
      );
    }
  }
}

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
