class Balance {

  final String currency_code;
  final String amount;

  Balance.fromJsonMap(Map<String, dynamic> map):
        currency_code = map["currency_code"],
        amount = map["amount"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency_code'] = currency_code;
    data['amount'] = amount;
    return data;
  }
}