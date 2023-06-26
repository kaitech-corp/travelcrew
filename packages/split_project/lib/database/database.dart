
import '../models/payment.dart';
import '../models/split_item.dart';
import '../models/user.dart';

class Database {

  // CRUD operations for SplitItem
  Future<void> createSplitItem(SplitItem splitItem) async {
    // Implementation
  }

  Future<SplitItem?> getSplitItem(String docID) async {
    // Implementation
  }

  Future<void> updateRemainingBalance(String docID, double remainingBalance) async {
    // Implementation
  }

  // CRUD operations for User
  Future<void> createUser(User user) async {
    // Implementation
  }

  Future<User?> getUser(String uid) async {
    // Implementation
  }

  // CRUD operations for Payment
  Future<void> createPayment(Payment payment) async {
    // Implementation
  }

  Future<Payment?> getPayment(String docID) async {
    // Implementation
  }
}
