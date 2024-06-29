import 'dart:math'; // Import the dart:math library

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services to access clipboard
import 'package:intl/intl.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instant Calculator',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  dynamic displaytxt = 20;

  // Button Widget
  Widget calcbutton(String btntxt, Color? btncolor, Color txtcolor) {
    btncolor ??= Colors.grey;
    return Container(
      margin: EdgeInsets.all(5), // Add margin to increase the space between buttons
      child: SizedBox(
        width: 77,
        height: 77,
        child: ElevatedButton(
          onPressed: () {
            calculation(btntxt);
          },
          child: btntxt == '⌫'
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    Icons.backspace,
                    color: txtcolor,
                  ),
                )
              : Text(
                  '$btntxt',
                  style: TextStyle(
                    fontSize: 50,
                    color: txtcolor,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: btncolor,
            padding: EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }

  // History list
  List<String> history = [];

  @override
  Widget build(BuildContext context) {
    // Calculator
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: copyHistoryToClipboard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // History display at the top right corner
              Container(
                height: 100,
                alignment: Alignment.topRight,
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return Text(
                      history[index],
                      style: TextStyle(
                        color: const Color.fromARGB(255, 126, 110, 110),
                        fontSize: 35,
                      ),
                    );
                  },
                ),
              ),
              // Instant result display above the percentage button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '$instantResult',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
              // Calculator display
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        formatNumber('$text'),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  calcbutton('C', Color.fromARGB(255, 255, 153, 0), Colors.white),
                  calcbutton('⌫', const Color.fromARGB(255, 255, 153, 0), Colors.white), // Delete button
                  calcbutton('^', const Color.fromARGB(255, 255, 153, 0), Colors.white), // Changed from '+/-' to '^'
                  calcbutton('%', const Color.fromARGB(255, 255, 153, 0), Colors.white),
                ],
              ),
              SizedBox(height: 3), // Increase the space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  calcbutton('7', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('8', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('9', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('÷', Color.fromARGB(255, 255, 153, 0), Colors.white), // Changed from '/' to '÷'
                ],
              ),
              SizedBox(height: 3), // Increase the space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  calcbutton('4', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('5', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('6', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('x', Color.fromARGB(255, 255, 153, 0), Colors.white),
                ],
              ),
              SizedBox(height: 3), // Increase the space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  calcbutton('1', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('2', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('3', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('-', Color.fromARGB(255, 255, 153, 0), Colors.white),
                ],
              ),
              SizedBox(height: 3), // Increase the space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  calcbutton('0', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('.', Color.fromARGB(255, 78, 117, 115), Colors.white),
                  calcbutton('=', Color.fromARGB(255, 255, 153, 0), Colors.white),
                  calcbutton('+', Color.fromARGB(255, 255, 153, 0), Colors.white),
                ],
              ),
              SizedBox(height: 20), // Increase the space between rows
            ],
          ),
        ),
      ),
    );
  }

  // Calculator logic
  dynamic text = '0';
  dynamic instantResult = '0';
  double numOne = 0;
  double numTwo = 0;

  dynamic result = '';
  dynamic finalResult = '';
  dynamic opr = '';
  dynamic preOpr = '';

  double? initialNumOne;
  double? initialNumTwo;

  void calculation(String btnText) {
  if (btnText == 'C') {
    text = '0';
    numOne = 0;
    numTwo = 0;
    result = '';
    finalResult = '0';
    opr = '';
    preOpr = '';
    initialNumOne = null;
    initialNumTwo = null;
    history.clear(); // Clear history on reset
  } else if (btnText == '⌫') {
    if (result.length > 0) {
      result = result.substring(0, result.length - 1);
    }
    if (result == '') {
      result = '0';
    }
    finalResult = result;
  } else if (opr == '=' && btnText == '=') {
    if (preOpr == '+') {
      finalResult = add();
    } else if (preOpr == '-') {
      finalResult = sub();
    } else if (preOpr == 'x') {
      finalResult = mul();
    } else if (preOpr == '÷') {
      finalResult = div();
    } else if (preOpr == '^') {
      finalResult = power();
    }
  } else if (btnText == '+' || btnText == '-' || btnText == 'x' || btnText == '÷' || btnText == '=' || btnText == '^') {
    if (numOne == 0) {
      numOne = double.parse(result);
      initialNumOne = numOne;
    } else {
      numTwo = double.parse(result);
      initialNumTwo = numTwo;
    }

    if (opr != '') {
      if (opr == '+') {
        finalResult = add();
      } else if (opr == '-') {
        finalResult = sub();
      } else if (opr == 'x') {
        finalResult = mul();
      } else if (opr == '÷') {
        finalResult = div();
      } else if (opr == '^') {
        finalResult = power();
      }

      if (btnText == '=') {
        history.add('${initialNumOne ?? numOne} $opr ${initialNumTwo ?? numTwo} = $finalResult');
      }
      
      numOne = double.parse(finalResult);
      numTwo = 0;
    }

    if (btnText != '=') {
      opr = btnText;
    } else {
      opr = '';
    }
    
    result = '';
  } else if (btnText == '%') {
    if (numOne != 0 && result.isNotEmpty) {
      result = (double.parse(result) / 100).toString();
    } else {
      result = (numOne / 100).toString();
    }
    finalResult = doesContainDecimal(result);
  } else if (btnText == '.') {
    if (!result.toString().contains('.')) {
      result = result.toString() + '.';
    }
    finalResult = result;
  } else {
    result = result + btnText;
    finalResult = result;
  }

  setState(() {
    text = finalResult;
    instantResult = calculateInstantResult(); // Update instant result
  });
}

String calculateInstantResult() {
  if (numOne != 0 && opr.isNotEmpty && result.isNotEmpty) {
    numTwo = double.parse(result);
    String instant = '$numOne $opr $numTwo';
    if (opr == '+') {
      return '$instant = ${doesContainDecimal((numOne + numTwo).toString())}';
    } else if (opr == '-') {
      return '$instant = ${doesContainDecimal((numOne - numTwo).toString())}';
    } else if (opr == 'x') {
      return '$instant = ${doesContainDecimal((numOne * numTwo).toString())}';
    } else if (opr == '÷') {
      return '$instant = ${doesContainDecimal((numOne / numTwo).toString())}';
    } else if (opr == '^') {
      return '$instant = ${doesContainDecimal(pow(numOne, numTwo).toString())}';
    }
  }
  return finalResult;
}


  String add() {
    result = (numOne + numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String sub() {
    result = (numOne - numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String mul() {
    result = (numOne * numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String div() {
    result = (numOne / numTwo).toString();
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String power() {
    result = pow(numOne, numTwo).toString(); // Use pow from dart:math
    numOne = double.parse(result);
    return doesContainDecimal(result);
  }

  String doesContainDecimal(dynamic result) {
    if (result.toString().contains('.')) {
      List<String> splitDecimal = result.toString().split('.');
      if (!(int.parse(splitDecimal[1]) > 0)) {
        return result = splitDecimal[0].toString();
      }
    }
    return result;
  }

  // Function to copy history to clipboard
  void copyHistoryToClipboard() {
    String historyText = history.join('\n');
    Clipboard.setData(ClipboardData(text: historyText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('History copied to clipboard!'),
        duration: Duration(seconds: 5), // Notification will be shown for 5 seconds
      ),
    );
  }

  String formatNumber(String number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(double.parse(number));
  }
}
