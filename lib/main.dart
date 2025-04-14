import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real-Time Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _expression = '';
  String _result = '0';
  bool _isResultDisplayed = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (_isResultDisplayed) {
        _expression = '';
        _result = '0';
        _isResultDisplayed = false;
      }

      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        _calculateResult();
      } else if (value == '=') {
        _calculateResult();
        _isResultDisplayed = true;
      } else {
        _expression += value;
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    try {
      // Replace × with * and ÷ with / for evaluation
      String evalExpression = _expression.replaceAll('×', '*').replaceAll('÷', '/');

      // Simple evaluation logic for basic arithmetic
      List<String> tokens = _tokenizeExpression(evalExpression);
      double result = _evaluateTokens(tokens);

      // Format result
      if (result.isFinite) {
        _result = result == result.roundToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      } else {
        _result = 'Error';
      }
    } catch (e) {
      _result = _expression.isEmpty ? '0' : 'Error';
    }
  }

  List<String> _tokenizeExpression(String expression) {
    List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if ('0123456789.'.contains(char)) {
        currentNumber += char;
      } else if ('+-*/'.contains(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }
    return tokens;
  }

  double _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) return 0;

    // First pass: handle * and /
    List<String> firstPass = [];
    double currentNumber;
    String? pendingOperator;

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];
      if (double.tryParse(token) != null) {
        currentNumber = double.parse(token);
        if (pendingOperator != null) {
          if (pendingOperator == '*') {
            firstPass[firstPass.length - 1] = (double.parse(firstPass.last) * currentNumber).toString();
          } else if (pendingOperator == '/') {
            if (currentNumber == 0) throw Exception('Division by zero');
            firstPass[firstPass.length - 1] = (double.parse(firstPass.last) / currentNumber).toString();
          }
          pendingOperator = null;
        } else {
          firstPass.add(token);
        }
      } else if (token == '*' || token == '/') {
        pendingOperator = token;
      } else {
        firstPass.add(token);
        pendingOperator = null;
      }
    }

    // Second pass: handle + and -
    double result = double.parse(firstPass[0]);
    for (int i = 1; i < firstPass.length; i += 2) {
      String operator = firstPass[i];
      double nextNumber = double.parse(firstPass[i + 1]);
      if (operator == '+') {
        result += nextNumber;
      } else if (operator == '-') {
        result -= nextNumber;
      }
    }

    return result;
  }

  Widget _buildButton(String text, {Color color = Colors.white, Color textColor = Colors.black}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(20),
            backgroundColor: color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: TextStyle(fontSize: 36, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _result,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('C', color: Colors.red[400]!, textColor: Colors.white),
                      _buildButton('⌫', color: Colors.orange[400]!, textColor: Colors.white),
                      _buildButton('÷', color: Colors.blue[400]!, textColor: Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×', color: Colors.blue[400]!, textColor: Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-', color: Colors.blue[400]!, textColor: Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+', color: Colors.blue[400]!, textColor: Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', color: Colors.green[400]!, textColor: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}