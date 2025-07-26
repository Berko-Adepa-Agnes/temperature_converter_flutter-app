import 'package:flutter/material.dart';

class TemperatureInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String selectedUnit;
  final List<String> units;
  final void Function(String?) onUnitChanged;

  const TemperatureInput({
    super.key,
    required this.controller,
    required this.label,
    required this.selectedUnit,
    required this.units,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: selectedUnit,
              items: units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: onUnitChanged,
            ),
          ],
        ),
      ],
    );
  }
}
