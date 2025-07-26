import 'package:flutter/material.dart';
import '../widgets/temperature_input.dart';
import '../widgets/conversion_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _temperatureController = TextEditingController();
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';
  String _result = '';
  String _errorMessage = '';

  void _convertTemperature() {
    final input = _temperatureController.text;

    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a value';
        _result = '';
      });
      return;
    }

    final double? value = double.tryParse(input);
    if (value == null) {
      setState(() {
        _errorMessage = 'Invalid number';
        _result = '';
      });
      return;
    }

    double converted;
    if (_fromUnit == _toUnit) {
      converted = value;
    } else if (_fromUnit == 'Celsius') {
      converted = _toUnit == 'Fahrenheit'
          ? value * 9 / 5 + 32
          : value + 273.15;
    } else if (_fromUnit == 'Fahrenheit') {
      converted = _toUnit == 'Celsius'
          ? (value - 32) * 5 / 9
          : (value - 32) * 5 / 9 + 273.15;
    } else {
      converted = _toUnit == 'Celsius'
          ? value - 273.15
          : (value - 273.15) * 9 / 5 + 32;
    }

    setState(() {
      _errorMessage = '';
      _result = '$value °$_fromUnit = ${converted.toStringAsFixed(2)} °$_toUnit';
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convertTemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TemperatureInput(
              controller: _temperatureController,
              errorMessage: _errorMessage,
              onChanged: (value) {
                if (_errorMessage.isNotEmpty) {
                  setState(() {
                    _errorMessage = '';
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ConversionSelector(
              fromUnit: _fromUnit,
              toUnit: _toUnit,
              onFromUnitChanged: (unit) => setState(() => _fromUnit = unit),
              onToUnitChanged: (unit) => setState(() => _toUnit = unit),
              onSwap: _swapUnits,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _convertTemperature,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Text(
                _result,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
