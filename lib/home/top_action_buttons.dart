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

// lib/widgets/top_action_buttons.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

Future<void> shutdownApp(BuildContext context) async {
  final dataProvider = Provider.of<DataProvider>(context, listen: false);
  final sizeConfig = Provider.of<SizeConfig>(context);

  try {
    // 🧹 Perform full cleanup and save synchronously or awaited
    await dataProvider.shutdown(); // make sure it's async-safe
  } catch (e) {
    // Optional: handle save error safely
    print('Error during shutdown: $e');
  }

  // 🕑 Give a small delay to ensure FFI writes finish
  await Future.delayed(const Duration(milliseconds: 300));

  // 🚪 Close the app properly
  if (Platform.isAndroid) {
    SystemNavigator.pop(); // gracefully close
  } else {
    exit(0); // for desktop/debug
  }
}

class TopActionButtons extends StatelessWidget {
  const TopActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.info_outline, color: Colors.amber),
              tooltip: 'App Info',
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Tulli Sudoku',
                  applicationVersion: '1.0.2',
                  applicationLegalese:
                      '© 2025 Mirko Thulke, Versailles, France',
                  children: [
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.feedback),
                      label: const Text('Send Feedback'),
                      onPressed: () {
                        FeedbackHelper.sendFeedback(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      licenseText,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            const SizedBox(width: 48), // ⬅️ Horizontal spacing
            IconButton(
              iconSize: 28, // ⬅️ Bigger icon
              icon: const Icon(Icons.help_outline, color: Colors.blue),
              tooltip: 'Help',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              },
            ),
            const SizedBox(width: 48), // ⬅️ Horizontal spacing
            IconButton(
              iconSize: 28, // ⬅️ Bigger icon
              icon: const Icon(Icons.power_settings_new, color: Colors.red),
              tooltip: 'Exit',
              onPressed: () async {
                await shutdownApp(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

const licenseText = '''
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
''';

// Copyright (c) 2025, MIRKO THULKE. All rights reserved.
// See LICENSE file in the project root for details.
