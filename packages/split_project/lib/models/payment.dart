class Payment {

  Payment({
    required this.docID,
    required this.splitItemDocID,
    required this.userUID,
    required this.amount,
    required this.date,
  });
  final String docID;
  final String splitItemDocID;
  final String userUID;
  final double amount;
  final DateTime date;
}
