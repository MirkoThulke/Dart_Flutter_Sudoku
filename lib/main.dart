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
  Text('Pairs'),
  Text('Triplets'),
  Text('...')
];

const List<Widget> undoiconlist = <Widget>[
  Icon(Icons.undo),
  Icon(Icons.redo),
];
/////////////////////////////////////

// typedefs
/////////////////////////////////////
typedef selectednumberlist = List<bool>;
typedef selectedsetresetlist = List<bool>;
typedef selectedpatternlist = List<bool>;
typedef selectedundoiconlist = List<bool>;
typedef highLightingOnBool = bool;
/////////////////////////////////////

// Debug Logging class
final log = Logger('SudokuLogger');

// Use Provider Class is used to exchange data between widgets
class DataProvider with ChangeNotifier {
  selectednumberlist _selectednumberlist = <bool>[
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

  selectedsetresetlist _selectedsetresetlist = <bool>[
    true,
    false,
    false,
    false
  ];

  selectedpatternlist _selectedpatternlist = <bool>[false, true, false];

  selectedundoiconlist _selectedundoiconlist = <bool>[true, false];

  highLightingOnBool _highLightingOnBool = false;

  void updateDataNumberlist(selectednumberlist _selectednumberlistNewData) {
    _selectednumberlist = _selectednumberlistNewData;
    notifyListeners();
  }

  void updateDataSelectedsetresetlist(
      selectedsetresetlist _selectedsetresetlistNewData) {
    _selectedsetresetlist = _selectedsetresetlistNewData;
    notifyListeners();
  }

  void updateDataSelectedpatternlist(
      selectedpatternlist _selectedpatternlistNewData) {
    _selectedpatternlist = _selectedpatternlistNewData;
    notifyListeners();
  }

  void updateDataSelectedundoiconlist(
      selectedundoiconlist _selectedundoiconlistNewData) {
    _selectedundoiconlist = _selectedundoiconlistNewData;
    notifyListeners();
  }

  void updateDataHighLightingOnBool(
      highLightingOnBool _highLightingOnBoolNewData) {
    _highLightingOnBool = _highLightingOnBoolNewData;
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
// but not greater than 0.66 of this dimension; to leave enough âve for the HMI segment.
// Height not smaller than aprox. 2cm
    safeBlockSudokuGridVertical =
        max(min(safeBlockVertical!, safeBlockHorizontal!) * 0.66, 80.0);

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
            child: SudokuGrid(),
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
        padding: const EdgeInsets.all(2),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: <Widget>[
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
        padding: const EdgeInsets.all(2),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        crossAxisCount: 3,
        // physics: const NeverScrollableScrollPhysics(), // no scrolling
        childAspectRatio: 1.0, // horozontal verus vertical aspect ratio
        children: <Widget>[
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
  selectednumberlist _selectednumberlistNewData = <bool>[
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

  selectedsetresetlist _selectedsetresetlistNewData = <bool>[
    true,
    false,
    false,
    false
  ];

  selectedpatternlist _selectedpatternlistNewData = <bool>[false, true, false];

  selectedundoiconlist _selectedundoiconlistNewData = <bool>[true, false];

  highLightingOnBool _highLightingOnBoolNewData = false;

  //  End HMI input variables////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////
  /* state variables :
  subelement_ChoiceState: bool, Number chosen = TRUE, only candidates = FALSE
  subelement_NumberChoice: Chosen Number (1...9)
  subelementlist_CandidateChoice[0, ..., 8]: Chosen Candidate Numbers -1 (boolean)
  */
  bool _subelementChoiceState = false; // No choice made
  var _subelementNumberChoice = 0; // Init value 0

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

  int _readNumberFromList(selectednumberlist _selectednumberlist) {
    int number = 0;

    // Check which number is selected (corresponding bit is TRUE)
    for (int i = 0; i < _selectednumberlist.length; i++) {
      if (_selectednumberlist[i] == true) {
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

  void _updateElementState(
      selectednumberlist _selectednumberlist,
      selectedsetresetlist _actionlist,
      selectedpatternlist _selectedpatternlist,
      selectedundoiconlist _selectedundoiconlist,
      highLightingOnBool _highLightingOnBoola) {
    setState(() {
      int _candNumber = 0;

      _candNumber = _readNumberFromList(_selectednumberlist);

      // Case 1 : User wants to add a candidate number
      if (_actionlist[0] == true) {
        _setCandidate(_candNumber);
      } else if (_actionlist[1] == true) {
        _resetCandidate(_candNumber);
      } else if (_actionlist[2] == true) {
        _setNumber(_candNumber);
      } else if (_actionlist[3] == true) {
        _resetNumber(_candNumber);
      } else {
        Logger.root.level = Level.ALL;
        log.shout('if _actionlist[] entered unintended ELSE statement');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // receive data from data provider triggered by HMI
    _selectednumberlistNewData =
        Provider.of<DataProvider>(context)._selectednumberlist;
    _selectedsetresetlistNewData =
        Provider.of<DataProvider>(context)._selectedsetresetlist;
    _selectedpatternlistNewData =
        Provider.of<DataProvider>(context)._selectedpatternlist;
    _selectedundoiconlistNewData =
        Provider.of<DataProvider>(context)._selectedundoiconlist;
    _highLightingOnBoolNewData =
        Provider.of<DataProvider>(context)._highLightingOnBool;

    return InkWell(
        onTap: () {
          setState(() {
            _updateElementState(
              _selectednumberlistNewData,
              _selectedsetresetlistNewData,
              _selectedpatternlistNewData,
              _selectedundoiconlistNewData,
              _highLightingOnBoolNewData,
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue[600],
          alignment: Alignment.center,
          child: !_subelementChoiceState // Result Number chosen ?
              ? GridView.count(
                  primary: true, // no scrolling
                  padding: const EdgeInsets.all(2),
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(), // no scrolling
                  childAspectRatio:
                      1.0, // horozontal verus vertical aspect ratio
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[0] == true)
                          ? Text("1",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("1",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[1] == true)
                          ? Text("2",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("2",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[2] == true)
                          ? Text("3",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("3",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[3] == true)
                          ? Text("4",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("4",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[4] == true)
                          ? Text("5",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("5",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[5] == true)
                          ? Text("6",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("6",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[6] == true)
                          ? Text("7",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("7",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[7] == true)
                          ? Text("8",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("8",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.teal[100],
                      child: (_subelementlistCandidateChoice[8] == true)
                          ? Text("9",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.9)))
                          : Text("9",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.2))),
                    ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Text('$_subelementNumberChoice'),
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
  selectednumberlist _selectednumberlist = <bool>[
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

  selectedsetresetlist _selectedsetresetlist = <bool>[
    true,
    false,
    false,
    false
  ];

  selectedpatternlist _selectedpatternlist = <bool>[false, true, false];
  selectedundoiconlist _selectedundoiconlist = <bool>[true, false];

  // variable to calculate max. size of button list
  double selectednumberlistWidthMax = 0.0;
  double selectedsetresetlistWidthMax = 0.0;
  double selectedpatternlistWidthMax = 0.0;
  double selectedundoiconlistWidthMax = 0.0;

  final bool _vertical = false; // constant setting
  bool _highLightingOn = true; // runtime setting

// State HMI variables END
///////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Dimension apply to individual buttons, thus must be divided by number of buttons in the array
    selectednumberlistWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectednumberlist.length);

    selectedsetresetlistWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedsetresetlist.length); // for futur use if required.

    selectedpatternlistWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedpatternlist.length); // for futur use if required.

    selectedundoiconlistWidthMax = SizeConfig.safeBlockHorizontal! *
        0.9 /
        max(1, _selectedundoiconlist.length); // for futur use if required.

    Logger.root.level = Level.ALL;
    log.info(
        'selectednumberlistWidthMax: $selectednumberlistWidthMax.toString()');
    log.info(
        'selectedsetresetlistWidthMax: $selectedsetresetlistWidthMax.toString()');
    log.info(
        'selectedpatternlistWidthMax: $selectedpatternlistWidthMax.toString()');
    log.info(
        'selectedundoiconlistWidthMax: $selectedundoiconlistWidthMax.toString()');

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(), // no scrolling
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ToggleButtons with a single selection.
              const SizedBox(height: 20),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedsetresetlist.length; i++) {
                      _selectedsetresetlist[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataSelectedsetresetlist(_selectedsetresetlist);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedsetresetlist,
                children: setresetlist,
              ),
              // ToggleButtons with a multiple selection.
              const SizedBox(height: 20),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    _selectedpatternlist[index] = !_selectedpatternlist[index];
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataSelectedpatternlist(_selectedpatternlist);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedpatternlist,
                children: patternlist,
              ),
              // ToggleButtons with icons only.
              const SizedBox(height: 20),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedundoiconlist.length; i++) {
                      _selectedundoiconlist[i] = i == index;
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataSelectedundoiconlist(_selectedundoiconlist);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: BoxConstraints(
                  minHeight: 20.0,
                  minWidth: 80.0,
                  // maxHeight: 60.0,
                  // maxWidth: SizeConfig.safeBlockHorizontal!,
                ),
                isSelected: _selectedundoiconlist,
                children: undoiconlist,
              ),
              // Click button list
              const SizedBox(height: 20),
              // Click button list
              const SizedBox(height: 5),
              ToggleButtons(
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectednumberlist.length; i++) {
                      _selectednumberlist[i] = i == index;
                      // Update data in the provider
                    }
                    Provider.of<DataProvider>(context, listen: false)
                        .updateDataNumberlist(_selectednumberlist);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints: BoxConstraints(
                  minHeight: selectednumberlistWidthMax *
                      0.5, // change optic of button
                  maxHeight: selectednumberlistWidthMax *
                      0.5, // change optic of button
                  minWidth: selectednumberlistWidthMax,
                  maxWidth: selectednumberlistWidthMax,
                ),
                isSelected: _selectednumberlist,
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
