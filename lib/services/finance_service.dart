import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/finance_transfer_model.dart';

class FinanceService {
  static Future<Map<String, dynamic>> beginMigrationReview(
    String tripId,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('beginFinanceMigrationReviewV3')
        .call(<String, dynamic>{'tripId': tripId});
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> previewMigrationReview(
    String tripId,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('previewFinanceMigrationReviewV3')
        .call(<String, dynamic>{'tripId': tripId});
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> commitMigrationReview(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('commitFinanceMigrationReviewV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> stageMigrationBatch(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('stageFinanceMigrationBatchV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> finishMigrationBatch(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('finishFinanceMigrationBatchV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> abortMigrationBatch(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('abortFinanceMigrationBatchV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, int>> getCurrencyOptions() async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('getFinanceCurrenciesV3')
        .call(<String, dynamic>{});
    final data = Map<String, dynamic>.from(response.data as Map);
    final options = data['currencies'] as List;
    return {
      for (final item in options)
        (item as Map)['code'] as String: (item['precision'] as num).toInt(),
    };
  }

  static CollectionReference<Map<String, dynamic>> expensesRef(
    String tripId, {
    FirebaseFirestore? database,
  }) => (database ?? firestore)
      .collection('trips')
      .doc(tripId)
      .collection('financeExpenses');

  static Future<List<FinanceExpenseModel>> getExpenses(
    String tripId, {
    FirebaseFirestore? database,
  }) async {
    final snapshot = await expensesRef(tripId, database: database).get();
    final result =
        snapshot.docs
            .where((doc) => doc.data()['isDeleted'] == false)
            .map(
              (doc) => FinanceExpenseModel.fromMap(doc.id, tripId, doc.data()),
            )
            .toList();
    result.sort((a, b) {
      final dateOrder = b.date.compareTo(a.date);
      return dateOrder == 0 ? a.id.compareTo(b.id) : dateOrder;
    });
    return result;
  }

  static Stream<List<FinanceExpenseModel>> watchExpenses(String tripId) =>
      expensesRef(tripId).snapshots().map((snapshot) {
        final result =
            snapshot.docs
                .where((doc) => doc.data()['isDeleted'] == false)
                .map(
                  (doc) =>
                      FinanceExpenseModel.fromMap(doc.id, tripId, doc.data()),
                )
                .toList();
        result.sort((a, b) {
          final dateOrder = b.date.compareTo(a.date);
          return dateOrder == 0 ? a.id.compareTo(b.id) : dateOrder;
        });
        return result;
      });

  static Stream<List<FinanceTransferModel>> watchTransfers(String tripId) =>
      firestore
          .collection('trips')
          .doc(tripId)
          .collection('financeTransfers')
          .snapshots()
          .map((snapshot) {
            final transfers =
                snapshot.docs
                    .map(
                      (doc) => FinanceTransferModel.fromMap(
                        doc.id,
                        tripId,
                        doc.data(),
                      ),
                    )
                    .toList();
            transfers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return transfers;
          });

  static Future<Map<String, dynamic>> recordTransfer(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('recordFinanceTransferV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> answerTransfer(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('answerFinanceTransferV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// The callable validates currency, allocations, membership and revision.
  /// Keep requestId stable across retries to receive the original result.
  static Future<Map<String, dynamic>> saveExpense(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('saveFinanceExpenseV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> deleteExpense(
    Map<String, dynamic> request,
  ) async {
    final response = await FirebaseFunctions.instance
        .httpsCallable('deleteFinanceExpenseV3')
        .call(request);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
