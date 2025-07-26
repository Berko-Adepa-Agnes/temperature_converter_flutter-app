import 'package:flutter/material.dart';

class ConversionSelector extends StatefulWidget {
  final String fromUnit;
  final String toUnit;
  final Function(String) onFromUnitChanged;
  final Function(String) onToUnitChanged;
  final VoidCallback onSwap;

  const ConversionSelector({super.key, 
    required this.fromUnit,
    required this.toUnit,
    required this.onFromUnitChanged,
    required this.onToUnitChanged,
    required this.onSwap,
  });

  @override
  _ConversionSelectorState createState() => _ConversionSelectorState();
}

class _ConversionSelectorState extends State<ConversionSelector>
    with TickerProviderStateMixin {
  final List<String> units = ['Celsius', 'Fahrenheit', 'Kelvin'];
  
  late AnimationController _swapController;
  late Animation<double> _swapAnimation;

  @override
  void initState() {
    super.initState();
    
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _swapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    _swapController.forward().then((_) {
      widget.onSwap();
      _swapController.reverse();
    });
  }

  Widget _buildUnitSelector({
    required String title,
    required String selectedUnit,
    required Function(String) onChanged,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedUnit,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: accentColor,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              dropdownColor: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              items: units.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: value == selectedUnit ? accentColor : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          value,
                          style: TextStyle(
                            color: value == selectedUnit ? accentColor : const Color(0xFF6B7280),
                            fontWeight: value == selectedUnit ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getUnitSymbol(value),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getUnitSymbol(String unit) {
    switch (unit) {
      case 'Celsius':
        return '°C';
      case 'Fahrenheit':
        return '°F';
      case 'Kelvin':
        return 'K';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // From unit selector
            Expanded(
              child: _buildUnitSelector(
                title: 'From',
                selectedUnit: widget.fromUnit,
                onChanged: widget.onFromUnitChanged,
                accentColor: const Color(0xFF3B82F6),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Swap button
            Column(
              children: [
                const SizedBox(height: 22), // Align with dropdown
                AnimatedBuilder(
                  animation: _swapAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _swapAnimation.value * 3.14159, // 180 degrees
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _handleSwap,
                            child: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // To unit selector
            Expanded(
              child: _buildUnitSelector(
                title: 'To',
                selectedUnit: widget.toUnit,
                onChanged: widget.onToUnitChanged,
                accentColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Conversion preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getUnitSymbol(widget.fromUnit),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getUnitSymbol(widget.toUnit),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}