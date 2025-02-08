import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku')),
      body: const Column(
        children: [
          Expanded(child: SudokuGrid()),
          Expanded(child: BadgeExample()),
        ],
      ),
    );
  }
}

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: <Widget>[
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
          Container(
            child: const SudokuElement(),
          ),
        ],
      ),
    );
  }
}

class SudokuElement extends StatefulWidget {
  const SudokuElement({super.key});

  @override
  State<SudokuElement> createState() => _SudokuElementState();
}

class _SudokuElementState extends State<SudokuElement> {
  final bool _isFavorited = true;
  final int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color.fromARGB(255, 204, 250, 210));
  }
}

class BadgeExample extends StatelessWidget {
  const BadgeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Badge(
              label: Text('Test'),
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.receipt),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Badge.count(
              count: 9999,
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
