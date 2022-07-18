import 'package:flutter/material.dart';

class AppLanguage {
  ///Default Language
  static const Locale defaultLanguage = Locale("en");

  ///List Language support in Application
  static final List<Locale> supportLanguage = [
    const Locale("en"),
    const Locale("vi"),
    const Locale("ar"),
    const Locale("da"),
    const Locale("de"),
    const Locale("el"),
    const Locale("fr"),
    const Locale("he"),
    const Locale("id"),
    const Locale("ja"),
    const Locale("ko"),
    const Locale("lo"),
    const Locale("nl"),
    const Locale("zh"),
    const Locale("fa"),
    const Locale("km"),
    const Locale("pt"),
    const Locale("ru"),
    const Locale("tr"),
    const Locale("hi"),
  ];

  ///Singleton factory
  static final AppLanguage _instance = AppLanguage._internal();

  factory AppLanguage() {
    return _instance;
  }

  AppLanguage._internal();
}
