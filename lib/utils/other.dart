import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';

class UtilOther {
  static fieldFocusChange(
    BuildContext context,
    FocusNode current,
    FocusNode next,
  ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  static hiddenKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<DeviceModel?> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        return DeviceModel(
          uuid: android.androidId,
          model: "Android",
          version: android.version.sdkInt.toString(),
          type: android.model,
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
        return DeviceModel(
          uuid: ios.identifierForVendor,
          name: ios.name,
          model: ios.systemName,
          version: ios.systemVersion,
          type: ios.utsname.machine,
        );
      }
    } catch (e) {
      UtilLogger.log("ERROR", e);
    }
    return null;
  }

  static Future<String?> getDeviceToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return await FirebaseMessaging.instance.getToken();
  }

  static Map<String, dynamic> buildFilterParams(FilterModel filter) {
    Map<String, dynamic> params = {
      "category": filter.category.map((item) {
        return item.id;
      }).toList(),
      "feature": filter.feature.map((item) {
        return item.id;
      }).toList(),
    };
    if (filter.location != null) {
      params['location'] = filter.location!.id;
    }
    if (filter.area != null) {
      params['location'] = filter.area!.id;
    }
    if (filter.minPrice != null) {
      params['price_min'] = filter.minPrice!.toInt();
    }
    if (filter.maxPrice != null) {
      params['price_max'] = filter.minPrice!.toInt();
    }
    if (filter.color != null) {
      params['color'] = filter.color;
    }
    if (filter.sort != null) {
      params['orderby'] = filter.sort!.field;
      params['order'] = filter.sort!.value;
    }
    return params;
  }

  ///Singleton factory
  static final UtilOther _instance = UtilOther._internal();

  factory UtilOther() {
    return _instance;
  }

  UtilOther._internal();
}
