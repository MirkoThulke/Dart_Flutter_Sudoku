import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Markdown(
            data: '''
# 🧩 Sudoku Help

This application is designed to help you solve Sudoku puzzles with visual ease.
The application is not generating puzzles but assists you in solving them by highlighting key features.
It also does not allow to revert back to previous states, in order to keep the focus on solving the puzzle at hand.
The application is intended for preparation to Sudoku competitions, hence the streamlined feature set.
You can call it 'Anti-cheat' Sudoku Solver 😄.

## 🔍 Features
Below are explanations of the main features available in the app.

**Mark Num** — Highlights all occurrences of the selected number.  
**Pairs** — Shows cells with only two remaining possible candidates (Naked/Hidden Pairs).  
**Singles** — Shows cells with only one remaining candidate.  
**Givens** — Displays the original numbers of the puzzle.

---

### 💡 Tips
- Tap a number to highlight it across the grid.  
- Use **Mark Num** to quickly spot conflicts or repetitions.  
- Toggle features on/off to explore solving strategies.
            ''',
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(fontSize: 16, height: 1.4),
              h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
