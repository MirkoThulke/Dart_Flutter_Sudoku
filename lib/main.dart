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

  /*
  subelementlist_states[0]: Chosen Number (1...9), No number chosen (0)
  subelementlist_states[1, ..., 9]: Chosen Candidate Numbers (boolean)
  */
  var subelementlist_states = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  State<SudokuElement> createState() => _SudokuElementState();
}

class _SudokuElementState extends State<SudokuElement> {
/*
  if(subelementlist_states[0]==1)
  {

  }
  else if (subelementlist_states[0]==0)
  {

  }
  else
  {
  assert(true, "state out of range. range : [0,1]");
  }
*/

  /* @override
    Widget build(BuildContext context) {
    return Container(color: const Color.fromARGB(255, 204, 250, 210)); */
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
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("1"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("2"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("3"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("4"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("5"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("6"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("7"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("8"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[100],
            child: const Text("9"),
          ),
        ],
      ),
    );
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
