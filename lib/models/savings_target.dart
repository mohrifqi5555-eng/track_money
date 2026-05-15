import 'package:flutter/material.dart';

class SavingsTarget {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final IconData icon;

  SavingsTarget({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'iconCode': icon.codePoint,
    };
  }

  factory SavingsTarget.fromMap(Map<String, dynamic> map) {
    return SavingsTarget(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
    );
  }
}
