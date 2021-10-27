import 'balance_model.dart';

class Groups {

  final int group_id;
  final List<Balance> balance;

  Groups.fromJsonMap(Map<String, dynamic> map):
        group_id = map["group_id"],
        balance = List<Balance>.from(map["balance"].map((it) => Balance.fromJsonMap(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_id'] = group_id;
    data['balance'] = balance != null ?
    this.balance.map((v) => v.toJson()).toList()
        : null;
    return data;
  }
}