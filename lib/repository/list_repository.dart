import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:listar/api/api.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class ListRepository {
  ///load setting
  static Future<void> loadSetting() async {
    final response = await Api.requestSetting();
    if (response.success) {
      final categories = List.from(response.data['categories'] ?? []).map(
        (item) {
          return CategoryModel.fromJson(item);
        },
      ).toList();
      final features = List.from(response.data['features'] ?? []).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
      final locations = List.from(response.data['locations'] ?? []).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
      final sorts = List.from(response.data['place_sort_option'] ?? []).map(
        (item) {
          return SortModel.fromJson(item);
        },
      ).toList();

      ListSetting.category = categories;
      ListSetting.features = features;
      ListSetting.locations = locations;
      ListSetting.sort = sorts;

      if (response.data['settings'] != null &&
          response.data['settings']['price_min'] != null) {
        ListSetting.minPrice =
            double.parse('${response.data['settings']['price_min']}');
      }
      if (response.data['settings'] != null &&
          response.data['settings']['price_min'] != null) {
        ListSetting.maxPrice =
            double.parse('${response.data['settings']['price_max']}');
      }
      if (response.data['settings'] != null &&
          response.data['settings']['color_option'] != null) {
        ListSetting.color =
            response.data['settings']['color_option'].cast<String>();
      }
      if (response.data['settings'] != null &&
          response.data['settings']['unit_price'] != null) {
        ListSetting.unit = response.data['settings']['unit_price'];
      }
      if (response.data['settings'] != null &&
          response.data['settings']['time_min'] != null) {
        List<String> split = response.data['settings']['time_min'].split(':');
        ListSetting.startHour = TimeOfDay(
          hour: int.tryParse(split[0]) ?? 0,
          minute: int.tryParse(split[1]) ?? 0,
        );
      }
      if (response.data['settings'] != null &&
          response.data['settings']['time_max'] != null) {
        List<String> split = response.data['settings']['time_max'].split(':');
        ListSetting.endHour = TimeOfDay(
          hour: int.tryParse(split[0]) ?? 0,
          minute: int.tryParse(split[1]) ?? 0,
        );
      }
      if (response.data['settings'] != null &&
          response.data['settings']['per_page'] != null) {
        ListSetting.perPage = response.data['settings']['per_page'];
      }
      if (response.data['settings'] != null &&
          response.data['settings']['list_mode'] != null) {
        final String view = response.data['settings']['list_mode'];
        if (view == 'list') {
          ListSetting.modeView = ProductViewType.list;
        }
        if (view == 'gird') {
          ListSetting.modeView = ProductViewType.gird;
        }
        if (view == 'list') {
          ListSetting.modeView = ProductViewType.block;
        }
      }
    } else {
      AppBloc.messageCubit.onShow(response.message);
    }
  }

  ///load list
  static Future<List?> loadList({
    int? page,
    int? perPage,
    FilterModel? filter,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
      "s": keyword,
    };
    if (filter != null) {
      params.addAll(UtilOther.buildFilterParams(filter));
    }
    final response = await Api.requestList(params);
    if (response.success) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load wish list
  static Future<List?> loadWishList({
    int? page,
    int? perPage,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
    };
    final response = await Api.requestWishList(params);
    if (response.success) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///add wishList
  static Future<bool> addWishList(id) async {
    final response = await Api.requestAddWishList({"post_id": id});
    AppBloc.messageCubit.onShow(response.message);
    if (response.success) {
      return true;
    }
    return false;
  }

  ///remove wishList
  static Future<bool> removeWishList(id) async {
    final response = await Api.requestRemoveWishList({"post_id": id});
    AppBloc.messageCubit.onShow(response.message);
    if (response.success) {
      return true;
    }
    return false;
  }

  ///clear wishList
  static Future<bool> clearWishList() async {
    final response = await Api.requestClearWishList();
    AppBloc.messageCubit.onShow(response.message);
    if (response.success) {
      return true;
    }
    return false;
  }

  ///load author post
  static Future<List?> loadAuthorList({
    required int page,
    required int perPage,
    required String keyword,
    required int userID,
    required FilterModel filter,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
      "s": keyword,
      "user_id": userID,
    };
    params.addAll(UtilOther.buildFilterParams(filter));
    final response = await Api.requestAuthorList(params);
    if (response.success) {
      final list = List.from(response.data ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();
      return [list, response.pagination, response.user];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Upload image
  static Future<ResultApiModel> uploadImage(File file, progress) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path),
    });
    return await Api.requestUploadImage(formData, progress);
  }

  ///load detail
  static Future<ProductModel?> loadProduct(id) async {
    final response = await Api.requestProduct({"id": id});
    if (response.success) {
      return ProductModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///save product
  static Future<bool> saveProduct(params) async {
    final response = await Api.requestSaveProduct(params);
    AppBloc.messageCubit.onShow(response.message);
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Delete author item
  static Future<bool> removeProduct(id) async {
    final response = await Api.requestDeleteProduct({"post_id": id});
    AppBloc.messageCubit.onShow(response.message);
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Delete author item
  static Future<List<String>?> loadTags(String keyword) async {
    final response = await Api.requestTags({"s": keyword});
    if (response.success) {
      return List.from(response.data ?? []).map((e) {
        return e['name'] as String;
      }).toList();
    }
    AppBloc.messageCubit.onShow(response.message);
    return [];
  }
}
