import 'package:worklink_local/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';


extension DatetimeExtensions on DateTime {

  static MultiLanguages get multi => MultiLanguages();

  bool isToday() {
    DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isTomorrow() {
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  bool isYesterday() {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool sameDate(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  Future<String> formatDate() async {
    return DateFormat('dd. MMMM. yyyy', await multi.getLocaleKey()).format(this);
  }

  Future<String> formatDateWithDay() async {
    return DateFormat('EEEE, dd. MMMM. yyyy', await multi.getLocaleKey()).format(this);
  }

  bool afterDays(int days) {
    DateTime targetDate = DateTime.now().add(Duration(days: days));
    logInfo('Checking if $this is after $targetDate');
    return isAfter(targetDate);
  }

} 