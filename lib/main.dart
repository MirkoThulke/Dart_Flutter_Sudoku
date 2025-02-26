import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

// constants
/////////////////////////////////////
const List<Widget> numberlist = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
  Text('4'),
  Text('5'),
  Text('6'),
  Text('7'),
  Text('8'),
  Text('9')
];

const List<Widget> setresetlist = <Widget>[
  Text('SetCand'),
  Text('ResetCand'),
  Text('SetNum'),
  Text('ResetNum')
];

const List<Widget> patternlist = <Widget>[
  Text('HlNumSelOn'),
  Text('HlAllNumOn'),
  Text('Pairs'),
  Text('MatchPairs'),
  Text('Twins'),
];

const List<Widget> undoiconlist = <Widget>[
  Icon(Icons.undo),
  Icon(Icons.redo),
];
/////////////////////////////////////

// typedefs
/////////////////////////////////////
typedef SelectedNumberList = List<bool>;
typedef SelectedSetResetList = List<bool>;
typedef SelectedPatternList = List<bool>;
typedef SelectedUndoIconList = List<bool>;
typedef HighLightingOnBool = bool;
/////////////////////////////////////

// Debug Logging class
final log = Logger('SudokuLogger');

// Use Provider Class is used to exchange data between widgets
class DataProvider with ChangeNotifier {
  SelectedNumberList _selectedNumberList = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  SelectedSetResetList _selectedSetResetList = <bool>[
    true,
    false,
    false,
    false
  ];

  SelectedPatternList _selectedPatternList = <bool>[
    true,
    false,
    false,
    false,
    false
  ];

  SelectedUndoIconList _selectedUndoIconList = <bool>[true, false];

  HighLightingOnBool _highLightingOnBool = false;

  void updateDataNumberlist(SelectedNumberList selectedNumberListNewData) {
    _selectedNumberList = selectedNumberListNewData;
    notifyListeners();
  }

  void updateDataselectedSetResetList(
      SelectedSetResetList selectedSetResetListNewData) {
    _selectedSetResetList = selectedSetResetListNewData;
    notifyListeners();
  }

  void updateDataselectedPatternList(
      SelectedPatternList selectedPatternListNewData) {
    _selectedPatternList = selectedPatternListNewData;
    notifyListeners();
  }

  void updateDataselectedUndoIconList(
      SelectedUndoIconList selectedUndoIconListNewData) {
    _selectedUndoIconList = selectedUndoIconListNewData;
    notifyListeners();
  }

  void updateDataHighLightingOnBool(
      HighLightingOnBool highLightingOnBoolNewData) {
    _highLightingOnBool = highLightingOnBoolNewData;
    notifyListeners();
  }
}

// Use this calss to handle the overall dimension of the app content depending on the actual screen size

/*
example :
@override
Widget build(BuildContext context) {
 return Center(
  child: Container(
   height: SizeConfig.blockSizeVertical * 20,
   width: SizeConfig.blockSizeHorizontal * 50,
   color: Colors.orange,
  ),
 );
}
// or use the safeSizeConfig.safeBlock... parameters
*/

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  static double? safeBlockAppBarGridVertical;
  static double? safeBlockSudokuGridVertical;
  static double? safeBlockHMIGridVertical;

  static double? safeBlockAppBarGridHorizontal;
  static double? safeBlockSudokuGridHorizontal;
  static double? safeBlockHMIGridHorizontal;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth!;
    blockSizeVertical = screenHeight!;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!);
    safeBlockVertical = (screenHeight! - _safeAreaVertical!);

// App screen space repartition in pixel :

// 5 percent height for AppBar, but not smaller than 20 logical pixel but smaller than aprox. 1 cm .
    safeBlockAppBarGridVertical = max(min(safeBlockVertical! * 0.05, 20.0), 40);

// Sudokugrid shall extend to the minimum of screen width / height,
// but not greater than 0.66 of this dimension; to leave enough space for the HMI segment.
// Height not smaller than aprox. 2cm

    if (safeBlockVertical! > safeBlockHorizontal!) {
      safeBlockSudokuGridVertical =
          min(safeBlockHorizontal!, safeBlockVertical! * 0.75);
    } else {
      safeBlockSudokuGridVertical = safeBlockVertical! * 0.75;
    }

    safeBlockSudokuGridVertical =
        min(safeBlockVertical! * 0.66, safeBlockHorizontal!);

// HMI height shall take the remaining space
    safeBlockHMIGridVertical = min(
        (safeBlockVertical! -
            safeBlockSudokuGridVertical! -
            safeBlockAppBarGridVertical!),
        80.0); // Not smaller than aprox. 2cm

    safeBlockAppBarGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockHMIGridHorizontal = safeBlockHorizontal!; // width of screen
    safeBlockSudokuGridHorizontal =
        safeBlockSudokuGridVertical!; // Grid shall be a square.

// Button min / max sizes :
    Logger.root.level = Level.ALL;

    log.info(
        'Horizontal size of screen in pixel: $SizeConfig.blockSizeHorizontal.toString()');
    log.info(
        'Vertical size of screen in pixel: $SizeConfig.blockSizeVertical.toString()');
    log.info(
        'Horizontal safe size of screen in pixel: $SizeConfig.safeBlockHorizontal.toString()');
    log.info(
        'Vertical safe size of screen in pixel: $SizeConfig.safeBlockVertical.toString()');
    log.info('AppBar height in pixel: $safeBlockAppBarGridVertical.toString()');
    log.info('Sudoku height in pixel: $safeBlockSudokuGridVertical.toString()');
    log.info('HMI height in pixel: $safeBlockHMIGridVertical.toString()');
  }
}

////////////////////////////////////////////////////////////
// Main classe  -> root
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: const MyApp(),
    ),
  );
}

////////////////////////////////////////////////////////////
// Homepage screen . This is the overall root screen
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // obtain current size of App on screen

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: SizeConfig.safeBlockAppBarGridVertical!, // 5 percent
          title: const Text('Sudoku')),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Align children vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align children horizontall
        children: [
          Container(
            height: SizeConfig.safeBlockSudokuGridVertical!,
            width: SizeConfig.safeBlockSudokuGridHorizontal!,
            color: Colors.orange,
            child: const SudokuGrid(),
          ),
/*
          // Test Code for definition of app segment sizes via simple containers with different color
          Container(
            // test container for app screen size definition
            height: SizeConfig
                .safeBlockSudokuGridVertical!, // Square with height equal to width equal to screen widths in percent
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.orange,
          ),
*/
          Expanded(
              child: Container(
            height: SizeConfig
                .safeBlockHMIGridVertical!, // what remaines if appbar and sudokugrid is placed
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.blue,
            child: ToggleButtonsSample(),
          ))
/*
          Expanded(
              child: Container(
            // user lower segement for potential filling in case of small gaps in size calcualtions
            // test container for app screen size definition
            height: SizeConfig
                .safeBlockHMIGridVertical!, // what remaines if appbar and sudokugrid is placed
            width: SizeConfig.safeBlockHorizontal!,
            color: Colors.blue,
          )),
*/
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TulliSudoku',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

//////////////////////////////////////////////////////////////////////////
/// Sudoku grid
//////////////////////////////////////////////////////////////////////////

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(1),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: const <Widget>[
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
          SudokuBlock(),
        ],
      ),
    );
  }
}

class SudokuBlock extends StatelessWidget {
  const SudokuBlock({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        primary: true,
        padding: const EdgeInsets.all(1),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: const <Widget>[
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
          SudokuElement(),
        ],
      ),
    );
  }
}
//////////////////////////////////////////////////////////////////////////
/// Sudoku grid element
//////////////////////////////////////////////////////////////////////////

class SudokuElement extends StatefulWidget {
  const SudokuElement({super.key});

  @override
  State<SudokuElement> createState() => _SudokuElementState();
}

class _SudokuElementState extends State<SudokuElement> {
  // _SudokuElementState({super.key});

  // HMI input variables
  SelectedNumberList _selectedNumberListNewData = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  SelectedSetResetList _selectedSetResetListNewData = <bool>[
    true,
    false,
    false,
    false
  ];

  SelectedPatternList _selectedPatternListNewData = <bool>[
    true,
    false,
    false,
    false,
    false
  ];

  SelectedUndoIconList _selectedUndoIconListNewData = <bool>[true, false];

  HighLightingOnBool _highLightingOnBoolNewData = false;

  //  End HMI input variables////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////
  /* state variables :
  subelement_ChoiceState: bool, Number chosen = TRUE, only candidates = FALSE
  subelement_NumberChoice: Chosen Number (1...9)
  subelementlist_CandidateChoice[0, ..., 8]: Chosen Candidate Numbers -1 (boolean)
  */
  bool _subelementChoiceState = false; // No choice made
  var _subelementNumberChoice = 0; // Init value 0
  Color _numberBackGroundColor = Color(0xFFFFFFFF); // white

  List<bool> _subelementlistCandidateChoice = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  int _readNumberFromList(SelectedNumberList selectedNumberList) {
    int number = 0;

    // Check which number is selected (corresponding bit is TRUE)
    for (int i = 0; i < selectedNumberList.length; i++) {
      if (selectedNumberList[i] == true) {
        number = i + 1;
      } else {
        // Add error handling here ...
      }
    }

    return number;
  }

  void _setNumber(int number) {
    setState(() {
      _subelementChoiceState = true;
      _subelementNumberChoice = number;
    });
  }

  void _resetNumber(int number) {
    setState(() {
      _subelementChoiceState = false;
      _subelementNumberChoice = 0;
    });
  }

  void _setCandidate(int number) {
    setState(() {
      _subelementlistCandidateChoice[number - 1] = true;
    });
  }

  void _resetCandidate(int number) {
    setState(() {
      _subelementlistCandidateChoice[number - 1] = false;
    });
  }

  Color _getNumberBackgroundColor() {
    Color _color = Color(0xFFFFFFFF); // opac white
    setState(() {
      if (_selectedPatternListNewData[0] ==
          true) // HighLighting Button Switched ON
      {
        _color = const Color.fromARGB(255, 248, 248, 35); // yellow highlighting
      } else {
        _color = const Color(0xFFFFFFFF); // keep white
      }
    });
    return _color;
  }

  void _updateElementState(
      SelectedNumberList selectedNumberList, SelectedSetResetList actionlist) {
    setState(() {
      int candNumber = 0;

      candNumber = _readNumberFromList(selectedNumberList);

      // Case 1 : User wants to add a candidate number
      if (actionlist[0] == true) {
        _setCandidate(candNumber);
      } else if (actionlist[1] == true) {
        _resetCandidate(candNumber);
      } else if (actionlist[2] == true) {
        _setNumber(candNumber);
      } else if (actionlist[3] == true) {
        _resetNumber(candNumber);
      } else {
        Logger.root.level = Level.ALL;
        log.shout('if actionlist[] entered unintended ELSE statement');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // receive data from data provider triggered by HMI
    _selectedNumberListNewData =
        Provider.of<DataProvider>(context)._selectedNumberList;
    _selectedSetResetListNewData =
        Provider.of<DataProvider>(context)._selectedSetResetList;
    _selectedPatternListNewData =
        Provider.of<DataProvider>(context)._selectedPatternList;
    _selectedUndoIconListNewData =
        Provider.of<DataProvider>(context)._selectedUndoIconList;
    _highLightingOnBoolNewData =
        Provider.of<DataProvider>(context)._highLightingOnBool;

    // obtain Color Change if Highlighting is On
    _numberBackGroundColor = _getNumberBackgroundColor();

    return InkWell(
        onTap: () {
          setState(() {
            _updateElementState(
                _selectedNumberListNewData, _selectedSetResetListNewData);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(1.0),
          color: Colors.blue[600],
          alignment: Alignment.center,
          child: !_subelementChoiceState // Result Number chosen ?
              ? GridView.count(
                  primary: true, // no scrolling
                  padding: const EdgeInsets.all(0.5),
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(), // no scrolling
                  childAspectRatio:
                      1.0, // horozontal verus vertical aspect ratio
                  children: <Widget>[
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[0] == true)
                              ? const Text("1",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("1",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[1] == true)
                              ? const Text("2",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("2",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[2] == true)
                              ? const Text("3",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("3",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[3] == true)
                              ? const Text("4",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("4",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[4] == true)
                              ? const Text("5",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("5",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[5] == true)
                              ? const Text("6",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("6",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[6] == true)
                              ? const Text("7",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("7",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[7] == true)
                              ? const Text("8",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text("8",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                    Container(
                      // padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      color: const Color.fromARGB(255, 235, 252, 250),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: (_subelementlistCandidateChoice[8] == true)
                              ? const Text("9",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900))
                              : Text("9",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.2),
                                      fontWeight: FontWeight.bold))),
                    ),
                  ],
                )
              : Container(
                  //  padding: const EdgeInsets.all(1),
                  alignment: Alignment.center,
                  color: const Color.fromARGB(255, 235, 252, 250),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text('$_subelementNumberChoice',
                          style: TextStyle(
                              color: Colors.black,
                              backgroundColor: _numberBackGroundColor,
                              fontWeight: FontWeight.w900))),
                ),
        ));
  }
}

//////////////////////////////////////////////////////////////////////////
/// HMI / buttons
//////////////////////////////////////////////////////////////////////////

class ToggleButtonsSample extends StatefulWidget {
  const ToggleButtonsSample({super.key});

  @override
  State<ToggleButtonsSample> createState() => _ToggleButtonsSampleState();
}

class _ToggleButtonsSampleState extends State<ToggleButtonsSample> {
///////////////////////////////////////////////////
  /// State HMI variables :
  SelectedNumberList _selectedNumberList = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  SelectedSetResetList _selectedSetResetList = <bool>[
    true,
    false,
    false,
    false
  ];

  SelectedPatternList _selectedPatternList = <bool>[
    true,
    false,
    false,
    false,
    false
  ];
  SelectedUndoIconList _selectedUndoIconList = <bool>[true, false];

  // variable to calculate max. size of button list
  double selectedNumberListWidthMax = 0.0;
  double selectedSetResetListWidthMax = 0.0;
  double selectedPatternListWidthMax = 0.0;
  double selectedUndoIconListWidthMax = 0.0;

  final bool _vertical = false; // constant setting
  bool _highLightingOn = true; // runtime setting

// State HMI variables END
///////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Dimension apply to individual buttons, thus must be divided by number of buttons in the array
    selectedNumberListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedNumberList.length);

    selectedSetResetListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedSetResetList.length); // for futur use if required.

    selectedPatternListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedPatternList.length); // for futur use if required.

    selectedUndoIconListWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedUndoIconList.length); // for futur use if required.

    Logger.root.level = Level.ALL;
    log.info(
        'selectedNumberListWidthMax: $selectedNumberListWidthMax.toString()');
    log.info(
        'selectedSetResetListWidthMax: $selectedSetResetListWidthMax.toString()');
    log.info(
        'selectedPatternListWidthMax: $selectedPatternListWidthMax.toString()');
    log.info(
        'selectedUndoIconListWidthMax: $selectedUndoIconListWidthMax.toString()');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(), // no scrolling
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ToggleButtons with a single selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedSetResetList.length; i++) {
                      _selectedSetResetList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedSetResetList(_selectedSetResetList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedSetResetList,
                children: setresetlist,
              ),
              // ToggleButtons with a multiple selection.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    _selectedPatternList[index] = !_selectedPatternList[index];
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedPatternList(_selectedPatternList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedPatternList,
                children: patternlist,
              ),
              // ToggleButtons with icons only.
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedUndoIconList.length; i++) {
                      _selectedUndoIconList[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataselectedUndoIconList(_selectedUndoIconList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: const BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedUndoIconList,
                children: undoiconlist,
              ),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedNumberList.length; i++) {
                      _selectedNumberList[i] = i == index;
                      // Update data in the provider
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataNumberlist(_selectedNumberList);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: BoxConstraints(
                  minHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  maxHeight: selectedNumberListWidthMax *
                      0.5, // change optic of button
                  minWidth: selectedNumberListWidthMax,
                  maxWidth: selectedNumberListWidthMax,
                ),
                isSelected: _selectedNumberList,
                children: numberlist,
              ),
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _highLightingOn = !_highLightingOn;
            Provider.of<DataProvider>(context, listen: false)
                .updateDataHighLightingOnBool(_highLightingOn);
          });
        },
        icon: const Icon(Icons.screen_rotation_outlined),
        label: Text(_highLightingOn ? 'highlight on' : 'highlight off'),
      ),*/
    );
  }
}
