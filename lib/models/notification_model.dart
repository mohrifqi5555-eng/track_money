class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String type; // 'transaction', 'alert', 'budget', 'saving', 'report'
  final double? amount;
  final String? status; // 'success', 'failed'

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.amount,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'amount': amount,
      'status': status,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      type: map['type'],
      amount: map['amount']?.toDouble(),
      status: map['status'],
    );
  }
}
