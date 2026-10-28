class FinanceAmount {
  static int parseMinor(String input, int precision) =>
      _parseMinor(input, precision, allowZero: false);

  static int parseShareMinor(String input, int precision) =>
      _parseMinor(input, precision, allowZero: true);

  static int _parseMinor(
    String input,
    int precision, {
    required bool allowZero,
  }) {
    if (precision < 0 ||
        precision > 4 ||
        !RegExp(r'^(0|[1-9][0-9]*)(\.[0-9]+)?$').hasMatch(input)) {
      throw const FormatException('Enter a valid amount.');
    }
    final parts = input.split('.');
    final fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > precision) {
      throw const FormatException('Too many decimal places.');
    }
    final scale = BigInt.from(10).pow(precision);
    final minor =
        BigInt.parse(parts[0]) * scale +
        BigInt.parse(
          fraction.padRight(precision, '0').isEmpty
              ? '0'
              : fraction.padRight(precision, '0'),
        );
    if (minor < (allowZero ? BigInt.zero : BigInt.one) ||
        minor > BigInt.from(1000000000000)) {
      throw const FormatException('Amount is outside the supported range.');
    }
    return minor.toInt();
  }

  static String toDecimal(int minor, int precision) {
    final scale = BigInt.from(10).pow(precision).toInt();
    final whole = minor ~/ scale;
    if (precision == 0) return '$whole';
    return '$whole.${(minor % scale).toString().padLeft(precision, '0')}';
  }
}
