/// Utility to enforce English digits (0-9) across all languages,
/// specifically fulfilling the requirement that Hindi localization
/// keeps numbers in Western Arabic / English digits rather than Devanagari numerals (०-९).
class NumberFormatter {
  const NumberFormatter._();

  static const Map<String, String> _devanagariToEnglishDigits = {
    '०': '0',
    '१': '1',
    '२': '2',
    '३': '3',
    '४': '4',
    '५': '5',
    '६': '6',
    '७': '7',
    '८': '8',
    '९': '9',
  };

  /// Converts any Devanagari numerals (०-९) within [input] to standard English digits (0-9).
  static String ensureEnglishDigits(String input) {
    if (input.isEmpty) return input;
    var result = input;
    _devanagariToEnglishDigits.forEach((devanagari, english) {
      result = result.replaceAll(devanagari, english);
    });
    return result;
  }

  /// Formats a numeric value using the Indian numbering grouping system
  /// (e.g. 2,36,000 or 2,450), strictly with English digits (0-9).
  static String formatIndianNumber(num number) {
    final isNegative = number < 0;
    final absNum = number.abs();
    final parts = absNum.toString().split('.');
    String integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (integerPart.length > 3) {
      final lastThree = integerPart.substring(integerPart.length - 3);
      final remaining = integerPart.substring(0, integerPart.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < remaining.length; i++) {
        if (i > 0 && (remaining.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(remaining[i]);
      }
      buffer.write(',');
      buffer.write(lastThree);
      integerPart = buffer.toString();
    }

    final formatted = '${isNegative ? '-' : ''}$integerPart$decimalPart';
    return ensureEnglishDigits(formatted);
  }

  /// Formats a currency amount with the Indian Rupee symbol (₹)
  /// and guaranteed English digits (e.g. ₹2,450 or ₹2,36,000).
  static String formatCurrency(num amount, {String symbol = '₹'}) {
    return '$symbol${formatIndianNumber(amount)}';
  }

  /// Formats a quantity with an optional unit (e.g. "100 qtl" or "180 क्विंटल").
  static String formatQuantity(num quantity, String unit) {
    final numString = ensureEnglishDigits(quantity.toString());
    return '$numString $unit';
  }

  /// Formats a percentage (e.g. "+3.4%" or "40%").
  static String formatPercentage(num percent, {bool includeSign = true, int decimals = 1}) {
    final sign = includeSign && percent > 0 ? '+' : '';
    final valueStr = percent % 1 == 0
        ? percent.toInt().toString()
        : percent.toStringAsFixed(decimals);
    return '$sign${ensureEnglishDigits(valueStr)}%';
  }

  /// Formats a date using English digits (e.g. "12/09/2026").
  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return ensureEnglishDigits('$d/$m/$y');
  }

  /// Formats relative time keeping digits in English (e.g. "10 min ago" or "10 मिनट पहले").
  static String formatTimeAgo(int minutesAgo, {required bool isHindi}) {
    if (minutesAgo < 60) {
      return isHindi
          ? '${ensureEnglishDigits(minutesAgo.toString())} मिनट पहले'
          : '${ensureEnglishDigits(minutesAgo.toString())} min ago';
    } else if (minutesAgo < 1440) {
      final hours = (minutesAgo / 60).floor();
      if (isHindi) {
        return hours == 1
            ? '1 घंटा पहले'
            : '${ensureEnglishDigits(hours.toString())} घंटे पहले';
      } else {
        return hours == 1
            ? '1 hour ago'
            : '${ensureEnglishDigits(hours.toString())} hours ago';
      }
    } else {
      return isHindi ? 'कल' : 'Yesterday';
    }
  }
}
