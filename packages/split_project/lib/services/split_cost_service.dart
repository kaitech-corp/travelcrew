import 'package:flutter/foundation.dart';
import '../database/database.dart';
import '../models/payment.dart';
import '../models/split_item.dart';
import '../models/user.dart';
import '../repositories/payment_repository.dart';
import '../repositories/split_item_repository.dart';
import '../repositories/user_repository.dart';

class SplitCostService with ChangeNotifier {

  SplitCostService()
      : _splitItemRepository = SplitItemRepository(Database()),
        _userRepository = UserRepository(Database()),
        _paymentRepository = PaymentRepository(Database());
  final SplitItemRepository _splitItemRepository;
  final UserRepository _userRepository;
  final PaymentRepository _paymentRepository;

  Future<void> createSplitItem(SplitItem splitItem) async {
    await _splitItemRepository.createSplitItem(splitItem);
  }

  Future<SplitItem?> getSplitItem(String docID) async {
    return await _splitItemRepository.getSplitItem(docID);
  }

  Future<void> updateRemainingBalance(String docID, double remainingBalance) async {
    await _splitItemRepository.updateRemainingBalance(docID, remainingBalance);
  }

  Future<void> createUser(User user) async {
    await _userRepository.createUser(user);
  }

  Future<User?> getUser(String uid) async {
    return await _userRepository.getUser(uid);
  }

  Future<void> createPayment(Payment payment) async {
    await _paymentRepository.createPayment(payment);
  }

  Future<Payment?> getPayment(String docID) async {
    return await _paymentRepository.getPayment(docID);
  }

  // Service methods
  void splitEvenly(SplitItem splitItem, List<User> users) {
    // Implementation
  }

  void splitCustom(SplitItem splitItem, List<User> users, List<double> amounts) {
    // Implementation
  }

  void makePayment(Payment payment) {
    // Implementation
  }
}
