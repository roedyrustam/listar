import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/logger.dart';

Map<String, dynamic> dioErrorHandle(DioError error) {
  UtilLogger.log("ERROR", error);

  switch (error.type) {
    case DioErrorType.response:
      UtilLogger.log("DioErrorType.response", error.response);
      if (error.response!.data is Map<String, dynamic>) {
        if (error.response?.statusCode == 403) {
          AppBloc.loginCubit.onLogout();
        }
        return error.response!.data;
      }
      return {"success": false, "message": "json_format_error"};
    case DioErrorType.sendTimeout:
    case DioErrorType.receiveTimeout:
      return {"success": false, "message": "request_time_out"};

    default:
      return {"success": false, "message": "connect_to_server_fail"};
  }
}

class HTTPManager {
  BaseOptions baseOptions = BaseOptions(
    baseUrl: 'https://listar.sikece.com/index.php/wp-json',
    connectTimeout: 30000,
    receiveTimeout: 30000,
    contentType: Headers.formUrlEncodedContentType,
    responseType: ResponseType.json,
  );

  ///On change domain
  void changeDomain(String domain) {
    baseOptions.baseUrl = '$domain/index.php/wp-json';
  }

  ///Setup Option
  BaseOptions exportOption(BaseOptions options) {
    Map<String, dynamic> header = {
      "Device-Id": Application.device?.uuid ?? '',
      "Device-Name": utf8.encode(Application.device?.name ?? ''),
      "Device-Model": Application.device?.model ?? '',
      "Device-Version": Application.device?.version ?? '',
      "Push-Token": Application.device?.token ?? '',
      "Type": Application.device?.type ?? '',
      "Lang": AppBloc.languageCubit.state.languageCode,
    };
    options.headers.addAll(header);
    UserModel? user = AppBloc.userCubit.state;
    if (user == null) {
      options.headers.remove("Authorization");
    } else {
      options.headers["Authorization"] = "Bearer ${user.token}";
    }
    return options;
  }

  ///Post method
  Future<dynamic> post({
    required String url,
    Map<String, dynamic>? data,
    FormData? formData,
    Options? options,
    Function(num)? progress,
    bool? loading,
  }) async {
    UtilLogger.log("POST URL", url);
    UtilLogger.log("DATA", data ?? formData);
    BaseOptions requestOptions = exportOption(baseOptions);
    UtilLogger.log("HEADERS", requestOptions.headers);

    Dio dio = Dio(requestOptions);

    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      final response = await dio.post(
        url,
        data: data ?? formData,
        options: options,
        onSendProgress: (sent, total) {
          if (progress != null) {
            progress((sent / total) / 0.01);
          }
        },
      );
      return response.data;
    } on DioError catch (error) {
      return dioErrorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  ///Get method
  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? params,
    Options? options,
    bool? loading,
  }) async {
    UtilLogger.log("GET URL", url);
    UtilLogger.log("PARAMS", params);
    BaseOptions requestOptions = exportOption(baseOptions);
    UtilLogger.log("HEADERS", requestOptions.headers);

    Dio dio = Dio(requestOptions);
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      final response = await dio.get(
        url,
        queryParameters: params,
      );
      return response.data;
    } on DioError catch (error) {
      return dioErrorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  factory HTTPManager() {
    return HTTPManager._internal();
  }

  HTTPManager._internal();
}

HTTPManager httpManager = HTTPManager();
