
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worklink_local/helpers/helpers.dart';

RegExp alphaRegExp = RegExp(r'^[a-zA-Z]+$');

// class with extension methods for String
extension StringExtension on String? {

  /// Returns true if given String is null or isEmpty
  bool get isEmptyOrNull => this == null || (this != null && this!.isEmpty) || (this != null && this! == 'null');

  // Check null string, return given value if null
  String validate({String value = ''}) {
    if (isEmptyOrNull) {
      return value;
    } else {
      return this!;
    }
  }

  // Validator for email
  bool get isEmail => RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(validate());

  /// Capitalize given String
  String capitalizeFirstLetter() => (validate().isNotEmpty) ? (this!.substring(0, 1).toUpperCase() + this!.substring(1).toLowerCase()) : validate();

  /// Check weather String is alpha or not
  bool isAlpha() => alphaRegExp.hasMatch(validate());

  // Toast a message
  void toast() {
    Fluttertoast.showToast(
      msg: validate(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  int toint() {
    try {
      return int.parse(validate());
    } catch (e) {
      return 0;
    }
  }

  DateTime toDateTime() {
    try {
      return DateTime.parse(validate());
    } catch (e) {
      return DateTime.now();
    }
  }

  Color toColor() {
    try {
      return Color(int.parse(validate().replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }

  // Check weather String is numeric or not
  bool isJson() {
    try {
      json.decode(validate());
    } catch (e) {
      return false;
    }
    return true;
  }

  // Capitalize first letter of each word
  String capitalizeEachWord() {
    return validate().split(' ').map((word) => word.capitalizeFirstLetter()).join(' ');
  }

  // Capitalize all letters
  String capitalize() {
    return validate().toUpperCase();
  }

  // Copy String to Clipboard
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: validate()));
  }

  /// for ex. add comma in price
  String formatNumberWithComma() {
    return validate().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  /// Removes white space from given String
  String removeAllWhiteSpace() => validate().replaceAll(RegExp(r"\s+\b|\b\s"), "");

  /// Render a HTML String
  String get renderHtml {
    return this!.replaceAll('&ensp;', ' ').replaceAll('&nbsp;', ' ').replaceAll('&emsp;', ' ').replaceAll('<br>', '\n').replaceAll('<br/>', '\n').replaceAll('&lt;', '<').replaceAll('&gt;', '>');
  }

  /// Return average read time duration of given String in seconds
  double calculateReadTime({int wordsPerMinute = 200}) {
    var words = countWords();
    var number = words / wordsPerMinute;
    return number;
  }

  /// Return number of words ina given String
  int countWords() {
    var words = validate().trim().split(RegExp(r'(\s+)'));
    return words.length;
  }

  /// Generate slug of a given String
  String toSlug({String delimiter = '_'}) {
    String text = validate().trim().toLowerCase();
    return text.replaceAll(' ', delimiter);
  }

  /// returns searchable array for Firebase Database
  List<String> setSearchParam() {
    String word = validate();

    List<String> caseSearchList = [];
    String temp = "";

    for (int i = 0; i < word.length; i++) {
      temp = temp + word[i];
      caseSearchList.add(temp.toLowerCase());
    }

    return caseSearchList;
  }
}