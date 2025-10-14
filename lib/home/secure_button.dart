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
      widget.onConfirmed();
    } else {
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

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.