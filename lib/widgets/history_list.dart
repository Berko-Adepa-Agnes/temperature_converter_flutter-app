import 'package:flutter/material.dart';
import '../models/conversion_history.dart';

class HistoryList extends StatelessWidget {
  final List<ConversionHistory> history;
  final void Function(ConversionHistory) onHistoryItemTap;

  const HistoryList({
    super.key,
    required this.history,
    required this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          leading: const Icon(Icons.thermostat, color: Colors.deepPurple),
          title: Text(
            '${item.inputValue}° ${item.fromUnit} → ${item.result.toStringAsFixed(2)}° ${item.toUnit}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${item.timestamp.toLocal()}'.split('.')[0],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () => onHistoryItemTap(item),
        );
      },
    );
  }
}
