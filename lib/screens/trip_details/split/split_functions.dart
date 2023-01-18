import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';

double calculateTotal(List<SplitObject> items) {
  double total = 0.00;

  for (final SplitObject item in items) {
    total += item.itemTotal;
  }

  return total;
}

List<String> listOfUserID(List<SplitObject> items) {
  final List<String> uids = <String>[];
  if (items.isNotEmpty) {
    for (final SplitObject item in items) {
      if (!uids.contains(item.purchasedByUID)) {
        uids.add(item.purchasedByUID);
      }
    }
  }
  return uids;
}

List<UserPurchaseDetails> calculateTotalPerUser(List<String> uids, List<SplitObject> items) {
  final List<UserPurchaseDetails> calculatedList = <UserPurchaseDetails>[];
  for (final String element in uids) {
    calculatedList.add(UserPurchaseDetails(uid: element, total: 0.00));
  }

  for (final SplitObject item in items) {
    for (final UserPurchaseDetails object in calculatedList) {
      if (object.uid == item.purchasedByUID) {
        object.total += item.itemTotal;
      }
    }
  }
  return calculatedList;
}
