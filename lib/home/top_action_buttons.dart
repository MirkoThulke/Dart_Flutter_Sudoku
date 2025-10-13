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

// lib/widgets/top_action_buttons.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

class TopActionButtons extends StatelessWidget {
  const TopActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 30.0, minWidth: 80.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.amber),
              tooltip: 'App Info',
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Tulli Sudoku',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      '© 2025 Mirko Thulke, Versailles, France',
                  children: const [
                    SizedBox(height: 12),
                    Text(
                      licenseText,
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.blue),
              tooltip: 'Help',
              onPressed: () {
                // Help logic
              },
            ),
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.red),
              tooltip: 'Exit',
              onPressed: () {
                // Shutdown logic
                final dataProvider =
                    Provider.of<DataProvider>(context, listen: false);

                dataProvider.shutdown(); // manually trigger cleanup
                // THEN close the app:
                SystemNavigator.pop(); // for Android
                // or exit(0); // for desktop/debug only — not recommended for production
              },
            ),
          ],
        ),
      ),
    );
  }
}

const licenseText = 'MIT License\n\n'
    'Permission is hereby granted, free of charge, to any person obtaining a copy '
    'of this software and associated documentation files (the "Software"), to deal '
    'in the Software without restriction, including without limitation the rights '
    'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
    'copies of the Software, and to permit persons to whom the Software is '
    'furnished to do so, subject to the following conditions:\n\n'
    'The above copyright notice and this permission notice shall be included in '
    'all copies or substantial portions of the Software.\n\n'
    'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
    'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
    'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
    'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER '
    'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING '
    'FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS '
    'IN THE SOFTWARE.';

// Copyright 2025, Mirko THULKE, Versailles
