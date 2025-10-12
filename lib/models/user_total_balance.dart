class UserTotalBalance {
  final double totalOwed;
  final double totalDue;
  final double netBalance;

  UserTotalBalance({
    required this.totalOwed,
    required this.totalDue,
    required this.netBalance,
  });

  factory UserTotalBalance.fromJson(Map<String, dynamic> json) {
    return UserTotalBalance(
      totalOwed: (json['total_owed'] ?? 0).toDouble(),
      totalDue: (json['total_due'] ?? 0).toDouble(),
      netBalance: (json['net_balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_owed': totalOwed,
        'total_due': totalDue,
        'net_balance': netBalance,
      };
} 