// import 'balance_model.dart';
//
// class Groups {
//
//   Groups.fromJsonMap(Map<String, dynamic> map):
//         group_id = map['group_id'],
//         balance = List<Balance>.from(map['balance'].map((it) => Balance.fromJsonMap(it)));
//
//   final int group_id;
//   final List<Balance> balance;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['group_id'] = group_id;
//     data['balance'] = balance != null ?
//     balance.map((Balance v) => v.toJson()).toList()
//         : null;
//     return data;
//   }
// }
