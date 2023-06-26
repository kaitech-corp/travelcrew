import '../database/database.dart';
import '../models/split_item.dart';

class SplitItemRepository {

  SplitItemRepository(this._database);
  final Database _database;

  Future<void> createSplitItem(SplitItem splitItem) async {
    await _database.createSplitItem(splitItem);
  }

  Future<SplitItem?> getSplitItem(String docID) async {
    return await _database.getSplitItem(docID);
  }

  Future<void> updateRemainingBalance(String docID, double remainingBalance) async {
    await _database.updateRemainingBalance(docID, remainingBalance);
  }
}
