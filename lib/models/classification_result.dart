class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({
    required this.label,
    required this.confidence,
  });

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(2)}%';

  @override
  String toString() => 'ClassificationResult(label: $label, confidence: $confidencePercentage)';
}
