class AnalyticsStatEntity {
  final String icon;
  final String value;
  final String label;
  final String change;
  final bool isPositive;

  const AnalyticsStatEntity({
    required this.icon,
    required this.value,
    required this.label,
    required this.change,
    required this.isPositive,
  });
}
