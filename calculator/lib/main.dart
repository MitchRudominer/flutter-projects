import 'package:flutter/material.dart';
import 'tokenCalculator.dart';

void main() {
  runApp(new MaterialApp(
      title: 'Calculator',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Calculator()));
}

class Calculator extends StatefulWidget {
  Calculator({Key key}) : super(key: key);

  @override
  _CalculatorState createState() => new _CalculatorState();
}

enum EntryState {
  Start, // A new number must be started now
  LeadingNeg, // A new number without a leading negative must be started now
  Number, // We are in the midst of a number without a point
  LeadingPoint, // A new number without a leading negative or point must start
  NumberWithPoint, // We are in the midst of a number with a point
  Result, // A result is being displayed
}

class _CalculatorState extends State<Calculator> {
  List<String> _keyPressHistory = <String>[];
  List<EntryState> _entryStateStack = <EntryState>[];
  List<TokenList> _tokenListStack = <TokenList>[];
  EntryState _entryState = EntryState.Start;
  TokenList _tokenList = new TokenList.Empty();

  pushState(EntryState state) {
    _entryStateStack.add(_entryState);
    _entryState = state;
  }

  popState() {
    if (_entryStateStack.length > 0) {
      _entryState = _entryStateStack.removeLast();
    } else {
      _entryState = EntryState.Start;
    }
  }

  pushTokenList(TokenList tokenList) {
    _tokenListStack.add(_tokenList);
    _tokenList = tokenList;
  }

  popTokenList() {
    if ( _tokenListStack.length > 0) {
      _tokenList =  _tokenListStack.removeLast();
    } else {
      _tokenList = new TokenList.Empty();
    }
  }

  pushDigit(int digit) {
    pushTokenList(_tokenList.appendDigit(digit));
  }

  pushLeadingNeg() {
    pushTokenList(_tokenList.appendLeadingNeg());
  }

  pushPoint() {
    pushTokenList(_tokenList.appendPoint());
  }

  pushOperation(Operation op) {
    pushTokenList(_tokenList.appendOperation(op));
  }

  computeResult() {
    // TODO(rudominer) Compute the real result.
    var result = _tokenList.compute();
    print(_tokenList.toString());
    _tokenListStack.clear();
    _keyPressHistory.clear();
    _keyPressHistory.add("$result");
    _entryStateStack.clear();
    _entryState = EntryState.Result;
  }

  onNumberTap(int n) {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.Number:
        pushState(EntryState.Number);
        break;
      case EntryState.LeadingPoint:
      case EntryState.NumberWithPoint:
        pushState(EntryState.NumberWithPoint);
        break;
      case EntryState.Result:
        // Cannot enter a number now
        return;
    }
    setState(() {
      pushDigit(n);
      _keyPressHistory.add("$n");
    });
  }

  onPointTap() {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.Number:
        pushState(EntryState.LeadingPoint);
        break;
      case EntryState.LeadingPoint:
      case EntryState.NumberWithPoint:
      case EntryState.Result:
        // Cannot enter a point now
        return;
    }
    setState(() {
      pushPoint();
      _keyPressHistory.add(".");
    });
  }

  onDelTap() {
    setState(() {
      popState();
      popTokenList();
      if (_keyPressHistory.length > 0) {
        _keyPressHistory.removeLast();
      }
    });
  }

  onPlusTap() {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.LeadingPoint:
        // Cannot enter operation now.
        return;
      case EntryState.Number:
      case EntryState.NumberWithPoint:
      case EntryState.Result:
        pushState(EntryState.Start);
        break;
    }
    setState(() {
      pushOperation(Operation.Addition);
      _keyPressHistory.add(" + ");
    });
  }

  onMinusTap() {
    switch (_entryState) {
      case EntryState.Start:
        pushState(EntryState.LeadingNeg);
        break;
      case EntryState.LeadingNeg:
      case EntryState.LeadingPoint:
        // Cannot enter operation now.
        return;
      case EntryState.Number:
      case EntryState.NumberWithPoint:
      case EntryState.Result:
        pushState(EntryState.Start);
        break;
    }
    setState(() {
      if (_entryState == EntryState.LeadingNeg) {
        pushLeadingNeg();
        _keyPressHistory.add("-");
      } else {
        pushOperation(Operation.Subtraction);
        _keyPressHistory.add(" - ");
      }
    });
  }

  onMultTap() {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.LeadingPoint:
        // Cannot enter operation now.
        return;
      case EntryState.Number:
      case EntryState.NumberWithPoint:
      case EntryState.Result:
        pushState(EntryState.Start);
        break;
    }
    setState(() {
      pushOperation(Operation.Multiplication);
      _keyPressHistory.add(" \u00D7 ");
    });
  }

  onDivTap() {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.LeadingPoint:
        // Cannot enter operation now.
        return;
      case EntryState.Number:
      case EntryState.NumberWithPoint:
      case EntryState.Result:
        pushState(EntryState.Start);
        break;
    }
    setState(() {
      pushOperation(Operation.Division);
      _keyPressHistory.add(" \u00F7 ");
    });
  }

  onEqualsTap() {
    switch (_entryState) {
      case EntryState.Start:
      case EntryState.LeadingNeg:
      case EntryState.LeadingPoint:
      case EntryState.Result:
        // Cannot enter equals now.
        return;
      case EntryState.Number:
      case EntryState.NumberWithPoint:
        break;
    }
    setState(() {
      computeResult();
    });
  }

  String buildDisplayContents() {
    var buffer = new StringBuffer("");
    buffer.writeAll(_keyPressHistory);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Calculator')),
        body: new Column(children: <Widget>[
          // Give the key-pad 3/5 of the vertical space.
          new CalcDisplay(2, buildDisplayContents()),
          new KeyPad(3, calcState: this)
        ]));
  }
}

class CalcDisplay extends StatelessWidget {
  CalcDisplay(this._flex, this._contents);

  int _flex;
  String _contents;

  @override
  Widget build(BuildContext context) {
    return new Flexible(
        flex: _flex,
        child: new Center(child: new Text(_contents,
            style: new TextStyle(color: Colors.black, fontSize: 24.0))));
  }
}

class KeyPad extends StatelessWidget {
  KeyPad(this._flex, {this.calcState});

  final int _flex;
  final _CalculatorState calcState;

  Widget build(BuildContext context) {
    return new Flexible(
        flex: _flex,
        child: new Row(children: <Widget>[
          new MainKeyPad(calcState: calcState),
          new OpKeyPad(calcState: calcState),
        ]));
  }
}

class MainKeyPad extends StatelessWidget {
  final _CalculatorState calcState;

  MainKeyPad({this.calcState});

  Widget build(BuildContext context) {
    return new Flexible(
        // We set flex equal to the number of columns so that the main keypad
        // and the op keypad have sizes proportional to their number of
        // columns.
        flex: 3,
        child: new Material(
            type: MaterialType.canvas,
            elevation: 12,
            color: Colors.indigo[400],
            child: new Column(children: <Widget>[
              new KeyRow(<Widget>[
                new NumberKey(7, calcState),
                new NumberKey(8, calcState),
                new NumberKey(9, calcState)
              ]),
              new KeyRow(<Widget>[
                new NumberKey(4, calcState),
                new NumberKey(5, calcState),
                new NumberKey(6, calcState)
              ]),
              new KeyRow(<Widget>[
                new NumberKey(1, calcState),
                new NumberKey(2, calcState),
                new NumberKey(3, calcState)
              ]),
              new KeyRow(<Widget>[
                new CalcKey(".", calcState.onPointTap),
                new NumberKey(0, calcState),
                new CalcKey("=", calcState.onEqualsTap),
              ])
            ])));
  }
}

class OpKeyPad extends StatelessWidget {
  final _CalculatorState calcState;

  OpKeyPad({this.calcState});

  Widget build(BuildContext context) {
    return new Flexible(child: new Material(
        type: MaterialType.canvas,
        elevation: 24,
        color: Colors.grey[700],
        child: new Column(children: <Widget>[
          new CalcKey("DEL", calcState.onDelTap),
          new CalcKey("\u00F7", calcState.onDivTap),
          new CalcKey("\u00D7", calcState.onMultTap),
          new CalcKey("-", calcState.onMinusTap),
          new CalcKey("+", calcState.onPlusTap)
        ])));
  }
}

class KeyRow extends StatelessWidget {
  List<Widget> keys;

  KeyRow(this.keys);

  Widget build(BuildContext context) {
    return new Flexible(child: new Row(
        mainAxisAlignment: MainAxisAlignment.center, children: this.keys));
  }
}

class CalcKey extends StatelessWidget {
  String text;
  GestureTapCallback onTap;
  CalcKey(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return new Flexible(child: new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.white)),
        child: new InkWell(
            onTap: this.onTap,
            child: new Center(child: new Text(this.text,
                style: new TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold))))));
  }
}

class NumberKey extends CalcKey {
  NumberKey(int value, _CalculatorState calcState)
      : super("$value", () {
          calcState.onNumberTap(value);
        });
}
