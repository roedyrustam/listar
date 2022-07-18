import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:listar/api/http_manager.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/repository/repository.dart';
import 'package:listar/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit() : super(ApplicationState.loading);

  ///On Setup Application
  void onSetup() async {
    ///Notify loading
    emit(ApplicationState.loading);

    ///Load Filter config non blocking
    ListRepository.loadSetting();

    ///Setup application
    final results = await Future.wait([
      PackageInfo.fromPlatform(),
      UtilOther.getDeviceInfo(),
      Firebase.initializeApp(),
      Preferences.setPreferences(),
    ]);

    Application.packageInfo = results[0] as PackageInfo;
    Application.device = results[1] as DeviceModel;

    ///Get old Theme & Font & Language
    final oldTheme = UtilPreferences.getString(Preferences.theme);
    final oldFont = UtilPreferences.getString(Preferences.font);
    final oldLanguage = UtilPreferences.getString(Preferences.language);
    final oldDarkOption = UtilPreferences.getString(Preferences.darkOption);
    final oldDomain = UtilPreferences.getString(Preferences.domain);

    DarkOption? darkOption;
    String? font;
    ThemeModel? theme;

    ///Setup domain
    if (oldDomain != null) {
      Application.domain = oldDomain;
    }

    ///Setup Language
    if (oldLanguage != null) {
      AppBloc.languageCubit.onUpdate(Locale(oldLanguage));
    }

    ///Find font support available [Dart null safety issue]
    try {
      font = AppTheme.fontSupport.firstWhere((item) {
        return item == oldFont;
      });
    } catch (e) {
      UtilLogger.log("ERROR", e);
    }

    ///Setup theme
    if (oldTheme != null) {
      theme = ThemeModel.fromJson(jsonDecode(oldTheme));
    }

    ///check old dark option
    if (oldDarkOption != null) {
      switch (oldDarkOption) {
        case 'off':
          darkOption = DarkOption.alwaysOff;
          break;
        case 'on':
          darkOption = DarkOption.alwaysOn;
          break;
        default:
          darkOption = DarkOption.dynamic;
      }
    }

    ///Setup Theme & Font with dark Option
    AppBloc.themeCubit.onChangeTheme(
      theme: theme,
      font: font,
      darkOption: darkOption,
    );

    ///Authentication begin check
    await AppBloc.authenticateCubit.onCheck();

    ///First or After upgrade version show intro preview app
    final hasReview = UtilPreferences.containsKey(
      '${Preferences.reviewIntro}.${Application.packageInfo?.version}',
    );
    if (hasReview) {
      ///Notify
      emit(ApplicationState.completed);
    } else {
      ///Notify
      emit(ApplicationState.intro);
    }
  }

  ///On Complete Intro
  void onCompletedIntro() async {
    await UtilPreferences.setBool(
      '${Preferences.reviewIntro}.${Application.packageInfo?.version}',
      true,
    );

    ///Notify
    emit(ApplicationState.completed);
  }

  ///On Change Domain
  void onChangeDomain(String domain) async {
    emit(ApplicationState.loading);
    final isDomain = Uri.tryParse(domain);
    if (isDomain != null) {
      Application.domain = domain;
      httpManager.changeDomain(domain);
      await UtilPreferences.setString(
        Preferences.domain,
        domain,
      );
      await Future.delayed(const Duration(milliseconds: 250));
      AppBloc.authenticateCubit.onClear();
      emit(ApplicationState.completed);
    } else {
      AppBloc.messageCubit.onShow('domain_not_correct');
    }
  }
}
