class SplitItem {

  SplitItem({
    required this.docID,
    required this.itemName,
    required this.itemDescription,
    required this.dateCreated,
    required this.dateUpdated,
    required this.itemType,
    required this.itemTotal,
    required this.tripDocID,
    required this.totalCost,
    required this.remainingBalance,
  });
  final String docID;
  final String itemName;
  final String itemDescription;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String itemType;
  final double itemTotal;
  final String tripDocID;
  final double totalCost;
  final double remainingBalance;
}
