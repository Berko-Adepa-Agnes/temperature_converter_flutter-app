import 'package:flutter/material.dart';
import '../widgets/temperature_input.dart';
import '../widgets/conversion_selector.dart';
import '../widgets/history_list.dart';
import '../models/conversion_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _inputController = TextEditingController();
  final List<String> _units = ['Celsius', 'Fahrenheit', 'Kelvin'];
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';
  String _result = '';
  final List<ConversionHistory> _history = [];

  void _convertTemperature() {
    double inputValue;
    try {
      inputValue = double.parse(_inputController.text);
    } catch (_) {
      setState(() {
        _result = 'Please enter a valid number';
      });
      return;
    }

    double output = _performConversion(inputValue, _fromUnit, _toUnit);

    setState(() {
      _result = '${output.toStringAsFixed(2)}° $_toUnit';
      _history.insert(
        0,
        ConversionHistory(
          inputValue: inputValue,
          fromUnit: _fromUnit,
          toUnit: _toUnit,
          result: output,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  double _performConversion(double value, String from, String to) {
    if (from == to) return value;

    if (from == 'Celsius') {
      if (to == 'Fahrenheit') return (value * 9 / 5) + 32;
      if (to == 'Kelvin') return value + 273.15;
    } else if (from == 'Fahrenheit') {
      if (to == 'Celsius') return (value - 32) * 5 / 9;
      if (to == 'Kelvin') return ((value - 32) * 5 / 9) + 273.15;
    } else if (from == 'Kelvin') {
      if (to == 'Celsius') return value - 273.15;
      if (to == 'Fahrenheit') return ((value - 273.15) * 9 / 5) + 32;
    }
    return value;
  }

  void _loadFromHistory(ConversionHistory item) {
    setState(() {
      _inputController.text = item.inputValue.toString();
      _fromUnit = item.fromUnit;
      _toUnit = item.toUnit;
      _result = '${item.result.toStringAsFixed(2)}° ${item.toUnit}';
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TemperatureInput(
              controller: _inputController,
              label: 'Input Temperature',
              selectedUnit: _fromUnit,
              units: _units,
              onUnitChanged: (value) => setState(() => _fromUnit = value!),
            ),
            const SizedBox(height: 20),
            ConversionSelector(
              units: _units,
              fromUnit: _fromUnit,
              toUnit: _toUnit,
              onFromChanged: (value) => setState(() => _fromUnit = value!),
              onToChanged: (value) => setState(() => _toUnit = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertTemperature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Convert', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Text(
                  'Result: $_result',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            const Text(
              'Conversion History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_history.isEmpty) const Text('No conversions yet.'),
            if (_history.isNotEmpty)
              HistoryList(
                  history: _history, onHistoryItemTap: _loadFromHistory),
          ],
        ),
      ),
    );
  }
}
