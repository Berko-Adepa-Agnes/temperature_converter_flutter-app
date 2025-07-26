class ConversionHistory {
  final double inputValue;
  final String fromUnit;
  final String toUnit;
  final double result;
  final DateTime timestamp;

  ConversionHistory({
    required this.inputValue,
    required this.fromUnit,
    required this.toUnit,
    required this.result,
    required this.timestamp,
  });
}
