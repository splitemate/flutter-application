class CurrentUser {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String accessToken;
  final String refreshToken;
  final double totalOwed;
  final double totalDue;
  final double netBalance;

  CurrentUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.imageUrl,
      required this.accessToken,
      required this.refreshToken,
      required this.totalOwed,
      required this.totalDue,
      required this.netBalance});

  factory CurrentUser.fromMap(Map<String, dynamic> map) {
    return CurrentUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['image_url'] ?? '',
      accessToken: map['access_token'] ?? '',
      refreshToken: map['refresh_token'] ?? '',
      totalOwed: (map['balance']['total_owed'] ?? 0).toDouble(),
      totalDue: (map['balance']['total_due'] ?? 0).toDouble(),
      netBalance: (map['balance']['net_balance'] ?? 0).toDouble(),
    );
  }

  factory CurrentUser.empty() {
    return CurrentUser(
        id: '',
        name: '',
        email: '',
        imageUrl: '',
        accessToken: '',
        refreshToken: '',
        totalOwed: 0,
        totalDue: 0,
        netBalance: 0);
  }
}
