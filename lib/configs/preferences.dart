import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? instance;

  static const String domain = 'domain';
  static const String reviewIntro = 'review';
  static const String user = 'user';
  static const String language = 'language';
  static const String notification = 'notification';
  static const String theme = 'theme';
  static const String darkOption = 'darkOption';
  static const String font = 'font';
  static const String search = 'search';

  static Future<void> setPreferences() async {
    instance = await SharedPreferences.getInstance();
  }

  ///Singleton factory
  static final Preferences _instance = Preferences._internal();

  factory Preferences() {
    return _instance;
  }

  Preferences._internal();
}
