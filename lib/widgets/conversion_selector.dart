import 'package:flutter/material.dart';

class ConversionSelector extends StatelessWidget {
  final String fromUnit;
  final String toUnit;
  final void Function(String) onFromUnitChanged;
  final void Function(String) onToUnitChanged;
  final VoidCallback onSwap;

  const ConversionSelector({
    super.key,
    required this.fromUnit,
    required this.toUnit,
    required this.onFromUnitChanged,
    required this.onToUnitChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final units = ['Celsius', 'Fahrenheit', 'Kelvin'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: fromUnit,
                items: units.map((unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                )).toList(),
                onChanged: (value) {
                  if (value != null) onFromUnitChanged(value);
                },
                decoration: const InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: onSwap,
              tooltip: 'Swap',
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: toUnit,
                items: units.map((unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                )).toList(),
                onChanged: (value) {
                  if (value != null) onToUnitChanged(value);
                },
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
