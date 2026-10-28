import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/finance_transfer_model.dart';

class FinanceBalance {
  static Map<String, int> compute({
    required String currencyCode,
    required List<FinanceExpenseModel> expenses,
    required List<FinanceTransferModel> transfers,
  }) {
    final balances = <String, int>{};
    void add(String uid, int amount) => balances.update(
      uid,
      (current) => current + amount,
      ifAbsent: () => amount,
    );

    for (final expense in expenses) {
      if (expense.currencyCode != currencyCode) {
        throw const FormatException('Mixed expense currencies.');
      }
      for (final entry in expense.payerAmountsMinor.entries) {
        add(entry.key, entry.value);
      }
      for (final entry in expense.sharesMinor.entries) {
        add(entry.key, -entry.value);
      }
    }
    for (final transfer in transfers) {
      if (transfer.currencyCode != currencyCode) {
        throw const FormatException('Mixed transfer currencies.');
      }
      if (transfer.status == 'confirmed') {
        add(transfer.fromUserId, transfer.amountMinor);
        add(transfer.toUserId, -transfer.amountMinor);
      }
    }
    if (balances.values.fold<int>(0, (sum, value) => sum + value) != 0) {
      throw const FormatException('Trip balances do not sum to zero.');
    }
    return balances;
  }
}
