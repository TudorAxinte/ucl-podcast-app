extension dateExtension on DateTime {
  String get formattedString {
    final day = this.day;
    final year = this.year;
    switch (this.month) {
      case 1:
        return "$day JANUARY $year";
      case 2:
        return "$day FEBRUARY $year";
      case 3:
        return "$day MARCH $year";
      case 4:
        return "$day APRIL $year";
      case 5:
        return "$day MAY $year";
      case 6:
        return "$day JUNE $year";
      case 7:
        return "$day JULY $year";
      case 8:
        return "$day AUGUST $year";
      case 9:
        return "$day SEPTEMBER $year";
      case 10:
        return "$day OCTOBER $year";
      case 11:
        return "$day NOVEMBER $year";
      case 12:
        return "$day DECEMBER $year";
      default:
        return "";
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
