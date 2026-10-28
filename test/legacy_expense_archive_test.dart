import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/views/expense/legacy_expense_archive.dart';

void main() {
  test(
    'raw archive labels malformed records without inferring money or settlement',
    () {
      final source = LegacyExpenseSource.fromRaw('Trip expense old', {
        'name': '',
        'amount': {'unexpected': true},
        'paidByUsers': ['traveler'],
      });
      expect(source.name, 'Unnamed historical record');
      expect(source.amount, 'Unknown amount');
      expect(source.date, 'Date unknown');
      expect(source.source, 'Trip expense old');
    },
  );
}
