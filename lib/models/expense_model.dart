import 'dart:convert';

class ExpenseModel {
  String? id;
  String tripId;
  String name;
  double amount;
  List<String> paidByUsers;
  String createdBy;
  DateTime date;
  ExpenseModel({
    this.id,
    required this.createdBy,
    required this.tripId,
    required this.name,
    required this.paidByUsers,
    required this.amount,
    required this.date,
  });

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
    final result = <String, dynamic>{};

    result.addAll({'createdBy': createdBy});
    result.addAll({'paidByUsers': paidByUsers});
    result.addAll({'id': id});
    result.addAll({'tripId': tripId});
    result.addAll({'name': name});
    result.addAll({'amount': amount});
    result.addAll({'date': date.toIso8601String()});

    return result;
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      paidByUsers: List<String>.from(map['paidByUsers'] ?? []),
      createdBy: map['createdBy'] ?? '',
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source));

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
