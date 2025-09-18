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
    this.splitType = 'equally',
    this.owedTo = const {},
    this.owners = const {},
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
      splitType: map['splitType'] as String? ?? 'equally',
      owedTo: Map<String, double>.from(map['owedTo'] as Map<String, dynamic>? ?? {}),
      owners: Map<String, double>.from(map['owners'] as Map<String, dynamic>? ?? {}),
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
  String splitType;
  Map<String, double> owedTo;
  Map<String, double> owners;

  ExpenseModel copyWith({
    String? id,
    String? tripId,
    String? name,
    String? createdBy,
    double? amount,
    List<String>? paidByUsers,
    DateTime? date,
    String? splitType,
    Map<String, double>? owedTo,
    Map<String, double>? owners,
  }) {
    return ExpenseModel(
      paidByUsers: paidByUsers ?? this.paidByUsers,
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      owedTo: owedTo ?? this.owedTo,
      owners: owners ?? this.owners,
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
      'splitType': splitType,
      'owedTo': owedTo,
      'owners': owners,
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
