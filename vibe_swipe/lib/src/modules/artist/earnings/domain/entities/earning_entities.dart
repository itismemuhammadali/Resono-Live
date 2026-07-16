class PerformanceEarning {
  const PerformanceEarning({
    required this.performanceTitle,
    required this.date,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.viewerCount,
    required this.tipCount,
  });

  final String performanceTitle;
  final DateTime date;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final int viewerCount;
  final int tipCount;
}

class PayoutRecord {
  const PayoutRecord({
    required this.amount,
    required this.date,
    required this.source,
    required this.status,
  });

  final double amount;
  final DateTime date;
  final String source;
  final PayoutStatus status;
}

enum PayoutStatus { pending, paid }
