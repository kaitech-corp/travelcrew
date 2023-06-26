import '../database/database.dart';
import '../models/payment.dart';

class PaymentRepository {

  PaymentRepository(this._database);
  final Database _database;

  Future<void> createPayment(Payment payment) async {
    await _database.createPayment(payment);
  }

  Future<Payment?> getPayment(String docID) async {
    return await _database.getPayment(docID);
  }
}
