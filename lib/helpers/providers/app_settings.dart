import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';
// import 'package:freeleads_app/modules/teams/models/collaborator_model.dart';

class AppSettings extends ChangeNotifier {
  // Singleton instance
  static final AppSettings _instance = AppSettings._internal();

  // Factory constructor that returns the singleton instance
  factory AppSettings() => _instance;

  // Private named constructor
  AppSettings._internal() {
    getSettings();
  }

  // Private instance variables
  Color _primaryLightColor = const Color.fromARGB(255, 108, 29, 255);
  Color _secondaryLightColor = Style.lightBlue;
  Color _accentLightColor = Style.yellow;

  Color _primaryDarkColor = const Color(0xFF6366F1);
  Color _secondaryDarkColor = const Color(0xFF818CF8);
  Color _accentDarkColor = const Color(0xFF94A3B8);

  bool _isDarkModeOn = false;
  bool _isSignedIn = false;
  bool _isOnboarding = false;
  bool _isBiometricEnabled = false;

  // App Info
  // CollaboratorModel? _user;
  String? _loginDate;
  String? _lastEnterDate;

  // ---- Getters ---- //
  static Color get primaryLightColor => _instance._primaryLightColor;
  static Color get secondaryLightColor => _instance._secondaryLightColor;
  static Color get accentLightColor => _instance._accentLightColor;
  static Color get primaryDarkColor => _instance._primaryDarkColor;
  static Color get secondaryDarkColor => _instance._secondaryDarkColor;
  static Color get accentDarkColor => _instance._accentDarkColor;

  static bool get isDarkModeOn => _instance._isDarkModeOn;
  static bool get isSignedIn => _instance._isSignedIn;
  static bool get doneOnboarding => _instance._isOnboarding;
  static bool get isBiometricEnabled => _instance._isBiometricEnabled;

  // static CollaboratorModel? get currentUser => _instance._user;
  static String? get loginDate => _instance._loginDate;
  static String? get lastEnterDate => _instance._lastEnterDate;

  // ---- Setters ---- //

  static set primaryLightColor(Color value) =>
      _instance._primaryLightColor = value;
  static set secondaryLightColor(Color value) =>
      _instance._secondaryLightColor = value;
  static set accentLightColor(Color value) =>
      _instance._accentLightColor = value;
  static set primaryDarkColor(Color value) =>
      _instance._primaryDarkColor = value;
  static set secondaryDarkColor(Color value) =>
      _instance._secondaryDarkColor = value;
  static set accentDarkColor(Color value) => _instance._accentDarkColor = value;

  static set isDarkModeOn(bool value) {
    _instance._isDarkModeOn = value;
    saveDarkMode(value);
  }

  static set isSignedIn(bool value) {
    _instance._isSignedIn = value;
  }

  static set isBiometricEnabled(bool value) {
    _instance._isBiometricEnabled = value;
    prefs.setBool('biometric_enabled', value);
  }

  static set doneOnboarding(bool value) {
    _instance._isOnboarding = value;
    saveOnboarding(value);
  }

  // static set currentUser(CollaboratorModel? value) {
  //   _instance._user = value;
  //   saveUser(value!);
  // }

  static set loginDate(String? date) {
    _instance._loginDate = date;
  }

  static set lastEnterDate(String? value) {
    logInfo('Setting last enter date: $value');
    _instance._lastEnterDate = value;
  }
  // ---- Functions ---- //

  notify() => notifyListeners();

  changeTheme() {
    isDarkModeOn = !isDarkModeOn;
    saveDarkMode(isDarkModeOn);
    notifyListeners();
  }

  changeLanguage(BuildContext context) async {
    await MultiLanguages.of(context)!.selectLanguageBottomSheet(context);
    notifyListeners();
  }

  /// --------- Functions to save and get settings --------- ///

  // Get all settings
  static Future<void> getSettings() async {
    isDarkModeOn = await getDarkMode();
    doneOnboarding = await getOnboarding();
    _instance._isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _instance._loginDate =
        prefs.getString(Constants.loginDateKey) ?? DateTime.now().toString();
  }

  static Future<bool> getBiometricEnabled() async {
    return prefs.getBool('biometric_enabled') ?? false;
  }

  static Future<void> syncBiometricPreference() async {
    _instance._isBiometricEnabled = await getBiometricEnabled();
    _instance.notifyListeners();
  }

  // ----------- SAVE VALUES ----------- //

  // Save signed in user
  // static Future<bool> saveUser(CollaboratorModel user) async {
  //   try {
  //     await prefs.setString('user', jsonEncode(user.toJson()));
  //     currentUser = user;
  //     isSignedIn = true;
  //     return true;
  //   } catch (e) {
  //     logError('Error on saving user: $e');
  //     return false;
  //   }
  // }

  // Save value of onboarding
  static Future<bool> saveOnboarding(bool value) async {
    return prefs.setBool(Constants.onboardingKey, value);
  }

  // Save value of dark mode
  static Future<bool> saveDarkMode(bool value) async {
    return prefs.setBool(Constants.darkModeKey, value);
  }

  // Save value of color from color picker
  static Future<bool> saveColor(String value) async {
    return prefs.setString('color', value);
  }

  // Save login date
  static Future<bool> saveLoginDate(String date) async {
    return prefs.setString(Constants.loginDateKey, date);
  }

  static Future<bool> saveBiometricEnabled(bool value) async {
    isBiometricEnabled = value;
    return true;
  }

  // Save last enter date
  static Future<bool> saveLastEnterDate(String date) async {
    return prefs.setString(Constants.lastEnterDateKey, date);
  }

  // ----------- GET VALUES ----------- //

  // Get signed in user
  // Future<CollaboratorModel?> getUser() async {
  //   String? userJson = prefs.getString('user');

  //   if (userJson != null) {
  //     currentUser = CollaboratorModel.fromJson(
  //       userJson as Map<String, dynamic>,
  //     );
  //   }

  //   return _user;
  // }

  // Get value of onboarding
  static Future<bool> getOnboarding() async {
    return prefs.getBool(Constants.onboardingKey) ?? false;
  }

  // Get value of dark mode
  static Future<bool> getDarkMode() async {
    return prefs.getBool(Constants.darkModeKey) ?? false;
  }

  // Get value of color from color picker
  static Future<String> getColor() async {
    return prefs.getString('color') ?? '0xFF000000';
  }

  // Get login date
  static Future<String> getLoginDate() async {
    return prefs.getString(Constants.loginDateKey) ?? DateTime.now().toString();
  }

  // Get last enter date
  static Future<String> getLastEnterDate() async {
    return prefs.getString(Constants.lastEnterDateKey) ??
        DateTime.now().toString();
  }
}
