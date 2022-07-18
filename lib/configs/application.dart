import 'package:listar/models/model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Application {
  static bool debug = false;
  static String googleAPI = 'AIzaSyAGHlk0PoZ-BdSwUJh_HGSHXWKlARE4Pt8';
  static String domain = 'https://listarapp.com';
  static DeviceModel? device;
  static PackageInfo? packageInfo;

  ///Singleton factory
  static final Application _instance = Application._internal();

  factory Application() {
    return _instance;
  }

  Application._internal();
}
