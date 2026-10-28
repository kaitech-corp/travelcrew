import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/finance_amount.dart';

void main() {
  test('parses supported minor-unit precision exactly', () {
    expect(FinanceAmount.parseMinor('10.01', 2), 1001);
    expect(FinanceAmount.parseMinor('101', 0), 101);
    expect(FinanceAmount.parseMinor('1.234', 3), 1234);
    expect(FinanceAmount.parseShareMinor('0', 2), 0);
    expect(FinanceAmount.toDecimal(1001, 2), '10.01');
    expect(FinanceAmount.toDecimal(101, 0), '101');
  });

  test('rejects rounding, exponent, negative and oversized amounts', () {
    for (final input in ['1.001', '1e2', '-1', '01', 'NaN', '0']) {
      expect(
        () => FinanceAmount.parseMinor(input, 2),
        throwsFormatException,
        reason: input,
      );
    }
    expect(() => FinanceAmount.parseMinor('1.5', 0), throwsFormatException);
    expect(
      () => FinanceAmount.parseMinor('1000000000001', 0),
      throwsFormatException,
    );
  });
}
