
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.category = 'Umum',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      isIncome: map['isIncome'] ?? false,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      category: map['category'] ?? 'Umum',
    );
  }
}
