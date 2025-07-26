import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TemperatureInput extends StatefulWidget {
  final Function(double) onTemperatureChanged;
  final Function(String) onError;

  const TemperatureInput({super.key, 
    required this.onTemperatureChanged,
    required this.onError, required Null Function(dynamic value) onChanged, required String errorMessage, required TextEditingController controller,
  });

  @override
  _TemperatureInputState createState() => _TemperatureInputState();
}

class _TemperatureInputState extends State<TemperatureInput>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _glowAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize animations
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _glowAnimation = ColorTween(
      begin: const Color(0xFF6366F1).withOpacity(0.0),
      end: const Color(0xFF6366F1).withOpacity(0.3),
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Focus listener
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      _hasError = false;
    });

    if (value.isEmpty) {
      widget.onError('Please enter a temperature value');
      _triggerShake();
      return;
    }

    // Check for invalid characters
    if (!RegExp(r'^-?\d*\.?\d*$').hasMatch(value)) {
      widget.onError('Please enter a valid number');
      _triggerShake();
      return;
    }

    try {
      double temperature = double.parse(value);
      
      // Check for extreme values
      if (temperature < -273.15) {
        widget.onError('Temperature cannot be below absolute zero (-273.15°C)');
        _triggerShake();
        return;
      }
      
      if (temperature > 1000000) {
        widget.onError('Temperature value is too large');
        _triggerShake();
        return;
      }

      widget.onTemperatureChanged(temperature);
      widget.onError('');
    } catch (e) {
      widget.onError('Invalid temperature format');
      _triggerShake();
    }
  }

  void _triggerShake() {
    setState(() {
      _hasError = true;
    });
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 
            ((_shakeController.value * 4).round() % 2 == 0 ? 1 : -1), 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _glowAnimation.value ?? Colors.transparent,
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Enter Temperature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Input field with beautiful styling
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasError 
                          ? Colors.red.withOpacity(0.5)
                          : _isFocused 
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFE5E7EB),
                      width: _isFocused ? 2 : 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., 25.5',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              onPressed: () {
                                _controller.clear();
                                widget.onTemperatureChanged(0.0);
                                widget.onError('');
                                setState(() {});
                              },
                            )
                          : const Icon(
                              Icons.thermostat_outlined,
                              color: Color(0xFF6B7280),
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _validateInput(value);
                    },
                  ),
                ),
                
                // Helper text
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Supports negative values and decimals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}