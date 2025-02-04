enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus fromString(String? status) {
    return ReceiptStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  final String recipient;
  final String transactionId;
  final ReceiptStatus status;
  final DateTime? timestamp;
  String? _id;
  String? get id => _id;

  Receipt({
    required this.recipient,
    required this.transactionId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'recipient': recipient,
    'message_id': transactionId,
    'status': status.value(),
    'timestamp': timestamp
  };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    var receipt = Receipt(
        recipient: json['recipient'],
        transactionId: json['transaction_id'],
        status: EnumParsing.fromString(json['status']),
        timestamp: json['timestamp']);
    receipt._id = json['id'];
    return receipt;
  }
}
