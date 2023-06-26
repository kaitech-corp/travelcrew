import '../database/database.dart';
import '../models/user.dart';

class UserRepository {

  UserRepository(this._database);
  final Database _database;

  Future<void> createUser(User user) async {
    await _database.createUser(user);
  }

  Future<User?> getUser(String uid) async {
    return await _database.getUser(uid);
  }
}
