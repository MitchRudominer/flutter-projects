class Token {
  String stringRep;

  Token(this.stringRep);

  String toString() {
    return stringRep;
  }
}

class IntToken extends Token {
  int number;

  IntToken(String stringRep) : super(stringRep) {
    number = int.parse(stringRep);
  }
}

class NumberToken extends Token {
  double number;

  NumberToken(String stringRep) : super(stringRep) {
    var toParse = stringRep;
    if (toParse.startsWith(".")) {
      toParse = "0" + toParse;
    }
    if (toParse.endsWith(".")) {
      toParse = toParse + "0";
    }
    number = double.parse(stringRep);
  }
}

class LeadingNegToken extends Token {
  LeadingNegToken() : super("-");
}

enum Operation { Addition, Subtraction, Multiplication, Division }

class OperationToken extends Token {
  Operation operation;

  OperationToken(Operation operation) : super(opString(operation)) ,this.operation=operation;

  static String opString(Operation operation) {
    switch (operation) {
      case Operation.Addition:
        return " + ";
      case Operation.Subtraction:
        return " - ";
      case Operation.Multiplication:
        return "  \u00D7  ";
      case Operation.Division:
        return "  \u00D7  ";
    }
  }
}

class TokenList {
  final List<Token> _list;
  TokenList(this._list);
  TokenList.Empty() : this(new List<Token>());
  TokenList.Result(NumberToken result) : _list = new List<Token>() {
    _list.add(result);
  }

  String toString() {
    return _list.toString();
  }

  TokenList appendDigit(int digit) {
    var outList = _list.toList();
    if (_list.length == 0 || _list.last is OperationToken) {
      outList.add(new IntToken("$digit"));
      return new TokenList(outList);
    }
    var last = outList.removeLast();
    if (last is LeadingNegToken) {
      outList.add(new IntToken("-$digit"));
    } else if (last is IntToken) {
      outList.add(new IntToken(last.stringRep + "$digit"));
    } else {
      outList.add(new NumberToken(last.stringRep + "$digit"));
    }
    print(last);
    print(outList.last);
    print("_____");
    return new TokenList(outList);
  }

  TokenList appendPoint() {
    if (_list.length > 0) {
      assert(!(_list.last is NumberToken));
    }
    var outList = _list.toList();
    if (outList.length == 0 || outList.last is Operation) {
      outList.add(new NumberToken("."));
    } else {
      var last = outList.removeLast();
      outList.add(new NumberToken(last.stringRep + "."));
    }
    return new TokenList(outList);
  }

  TokenList appendLeadingNeg() {
    if (_list.length > 0) {
      assert(_list.last is OperationToken);
    }
    var outList = _list.toList();
    outList.add(new LeadingNegToken());
    return new TokenList(outList);
  }

  TokenList appendOperation(Operation op) {
    assert(_list.length > 0);
    assert(_list.last is IntToken || _list.last is NumberToken);
    var outList = _list.toList();
    outList.add(new OperationToken(op));
    return new TokenList(outList);
  }

  num compute() {
    var first = _list.removeAt(0);
    var result = first.number;
    while (_list.length > 0) {
      var opToken = _list.removeAt(0);
      var numToken = _list.removeAt(0);
      if (opToken.operation == Operation.Addition) {
        result = result + numToken.number;
      } else if (opToken.operation == Operation.Subtraction) {
        result = result - numToken.number;
      } else if (opToken.operation == Operation.Multiplication) {
        result = result * numToken.number;
      } else {
        result = result / numToken.number;
      }
    }
    return result;
  }
}
