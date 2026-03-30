class InstallmentPlan {
  InstallmentPlan({
    required this.months,
    required this.totalAmount,
  });

  final int months;
  final double totalAmount;

  static const List<int> availablePlans = [0, 3, 6, 9, 12, 18, 24];

  double get monthlyPayment {
    if (months == 0) return totalAmount;
    return totalAmount / months;
  }

  bool get isPayInFull => months == 0;

  String getDisplayText(String locale) {
    if (isPayInFull) {
      return locale == 'ar' ? 'الدفع الكامل' : 'Pay in Full';
    }
    final monthsText = locale == 'ar' ? 'أشهر' : 'months';
    return '$months $monthsText';
  }

  Map<String, dynamic> toJson() {
    return {
      'installment_months': months,
      'monthly_payment': monthlyPayment,
      'total_amount': totalAmount,
    };
  }

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    return InstallmentPlan(
      months: json['installment_months'] ?? 0,
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
    );
  }

  static String formatCurrency(double amount, {String currency = 'SAR'}) {
    return '$amount $currency';
  }

  @override
  String toString() {
    if (isPayInFull) {
      return 'Pay in Full: ${formatCurrency(totalAmount)}';
    }
    return '$months months × ${formatCurrency(monthlyPayment)} = ${formatCurrency(totalAmount)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstallmentPlan &&
        other.months == months &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode => months.hashCode ^ totalAmount.hashCode;
}
