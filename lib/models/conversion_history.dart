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

  // Convert to string for debugging
  @override
  String toString() {
    return 'ConversionHistory(input: $inputValue $fromUnit, result: $result $toUnit, time: $timestamp)';
  }

  // Create a copy with different values
  ConversionHistory copyWith({
    double? inputValue,
    String? fromUnit,
    String? toUnit,
    double? result,
    DateTime? timestamp,
  }) {
    return ConversionHistory(
      inputValue: inputValue ?? this.inputValue,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}