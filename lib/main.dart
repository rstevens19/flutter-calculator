import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayInput = '';
  String _accumulatorDisplay = '0'; // Shows the accumulator with expression and result
  String _expression = '';

  final List<String> _buttonLabels = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '=', '+',
    'C'
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _clearAll();
      } else if (value == '=') {
        _calculateResult();
      } else if (value == '/' || value == '*' || value == '-' || value == '+') {
        _addOperator(value);
      } else if (value == '.') {
        _addDecimal();
      } else {
        _addNumber(value);
      }
    });
  }

  void _clearAll() {
    _displayInput = '';
    _accumulatorDisplay = '0';
    _expression = '';
  }

  void _addNumber(String num) {
    if (_displayInput.length < 20) {
      _displayInput += num;
      _updateDisplay();
    }
  }

  void _addDecimal() {
    // Prevent multiple decimals in the same number
    if (!_displayInput.contains('.') && _displayInput.isNotEmpty) {
      _displayInput += '.';
      _updateDisplay();
    }
  }

  void _addOperator(String operator) {
    if (_displayInput.isEmpty) return;

    _expression += _displayInput + operator;
    _displayInput = '';
    _accumulatorDisplay = _expression.trim();
  }

  void _calculateResult() {
    if (_displayInput.isEmpty) return;

    try {
      _expression += _displayInput;
      final expression = Expression.parse(_expression);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
      final formattedResult = _formatResult(result);
      
      // Show accumulator display with expression = result
      _accumulatorDisplay = '$_expression = $formattedResult';
      
      _displayInput = formattedResult;
      _expression = '';
    } catch (e) {
      _accumulatorDisplay = 'Error';
      _expression = '';
      _displayInput = '';
    }
  }

  void _updateDisplay() {
    if (_expression.isEmpty) {
      _accumulatorDisplay = _displayInput.isEmpty ? '0' : _displayInput;
    } else {
      _accumulatorDisplay = _expression + _displayInput;
    }
  }

  String _formatResult(dynamic result) {
    if (result is double) {
      if (result.isInfinite) {
        return 'Error';
      }
      if (result.isNaN) {
        return 'Error';
      }
      if (result == result.toInt()) {
        return result.toInt().toString();
      }
      return result.toStringAsFixed(10).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robbie Stevens Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Section
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Accumulator display
                  Text(
                    _accumulatorDisplay,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Buttons Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 5.0,
                ),
                itemCount: _buttonLabels.length,
                itemBuilder: (context, index) {
                  final label = _buttonLabels[index];
                  return _buildCalculatorButton(label);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(String label) {
    bool isOperator = label == '+' || label == '-' || label == '*' || label == '/';
    bool isEquals = label == '=';
    bool isClear = label == 'C';

    Color buttonColor;
    Color textColor;

    if (isClear) {
      buttonColor = const Color.fromARGB(255, 193, 10, 248);
      textColor = Colors.black;
    } else if (isOperator) {
      buttonColor = const Color.fromARGB(255, 187, 255, 0);
      textColor = Colors.black;
    } else if (isEquals) {
      buttonColor = const Color.fromARGB(255, 13, 60, 214);
      textColor = Colors.black;
    } else {
      buttonColor = const Color.fromARGB(255, 231, 16, 16);
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => _onButtonPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(300),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onButtonPressed(label),
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
