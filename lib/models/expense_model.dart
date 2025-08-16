import 'dart:convert';

class ExpenseModel {
  ExpenseModel({
    this.id,
    required this.createdBy,
    required this.tripId,
    required this.name,
    required this.paidByUsers,
    required this.amount,
    required this.date,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      paidByUsers: List<String>.from(map['paidByUsers'] as List<dynamic>? ?? []),
      createdBy: map['createdBy'] as String? ?? '',
      id: map['id'] as String?,
      tripId: map['tripId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
    );
  }

  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source) as Map<String, dynamic>);
  String? id;
  String tripId;
  String name;
  double amount;
  List<String> paidByUsers;
  String createdBy;
  DateTime date;

  ExpenseModel copyWith({
    String? id,
    String? tripId,
    String? name,
    String? createdBy,
    double? amount,
    List<String>? paidByUsers,
    DateTime? date,
  }) {
    return ExpenseModel(
      paidByUsers: paidByUsers ?? this.paidByUsers,
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdBy': createdBy,
      'paidByUsers': paidByUsers,
      'id': id,
      'tripId': tripId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ExpenseModel(id: $id, tripId: $tripId, name: $name, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseModel &&
        other.id == id &&
        other.tripId == tripId &&
        other.name == name &&
        other.amount == amount &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tripId.hashCode ^
        name.hashCode ^
        amount.hashCode ^
        date.hashCode;
  }
}
