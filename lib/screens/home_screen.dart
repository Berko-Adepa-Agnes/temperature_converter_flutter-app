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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _temperatureController = TextEditingController();
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';
  String _result = '';
  String _errorMessage = '';
  final List<ConversionHistory> _history = [];
  
  late AnimationController _buttonController;
  late AnimationController _resultController;
  late Animation<double> _buttonScale;
  late Animation<double> _resultFade;

  @override
  void initState() {
    super.initState();
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    _resultFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _buttonController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _convertTemperature() async {
    setState(() {
      _errorMessage = '';
    });

    final input = _temperatureController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a temperature value';
      });
      return;
    }

    final temperature = double.tryParse(input);
    if (temperature == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    // Button animation
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    // Convert temperature
    final convertedValue = _performConversion(temperature, _fromUnit, _toUnit);
    
    setState(() {
      _result = '${convertedValue.toStringAsFixed(2)}° $_toUnit';
      _history.insert(0, ConversionHistory(
        inputValue: temperature,
        fromUnit: _fromUnit,
        toUnit: _toUnit,
        result: convertedValue,
        timestamp: DateTime.now(),
      ));
    });

    // Result animation
    _resultController.reset();
    _resultController.forward();
  }

  double _performConversion(double value, String from, String to) {
    if (from == to) return value;

    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // Convert from Celsius to target unit
    switch (to) {
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temperature Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Temperature Input Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
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
                          }, onError: (String ) {  }, onTemperatureChanged: (double ) {  },
                        ),
                        const SizedBox(height: 20),
                        ConversionSelector(
                          fromUnit: _fromUnit,
                          toUnit: _toUnit,
                          onFromUnitChanged: (value) {
                            setState(() {
                              _fromUnit = value;
                            });
                          },
                          onToUnitChanged: (value) {
                            setState(() {
                              _toUnit = value;
                            });
                          },
                          onSwap: _swapUnits,
                        ),
                        const SizedBox(height: 25),
                        // Convert Button
                        AnimatedBuilder(
                          animation: _buttonScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScale.value,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _convertTemperature,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'Convert Temperature',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Result Display
                if (_result.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _resultFade,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _resultFade,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Result',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _result,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // History Section
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Conversion History',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _clearHistory,
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Clear'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          HistoryList(history: _history, onHistoryItemTap: (ConversionHistory ) {  },),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}