import 'package:flutter/material.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';

class FilterModel {
  late List<CategoryModel> category;
  late List<CategoryModel> feature;
  CategoryModel? area;
  CategoryModel? location;
  double? minPrice;
  double? maxPrice;
  String? color;
  SortModel? sort;
  TimeOfDay? startHour;
  TimeOfDay? endHour;

  FilterModel({
    required this.category,
    required this.feature,
    this.area,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.color,
    this.sort,
    this.startHour,
    this.endHour,
  });

  factory FilterModel.fromDefault() {
    return FilterModel(
      category: [],
      feature: [],
      sort: ListSetting.sort.isNotEmpty ? ListSetting.sort.first : null,
      startHour: ListSetting.startHour,
      endHour: ListSetting.endHour,
    );
  }

  FilterModel.fromSource(source) {
    category = List<CategoryModel>.from(source.category);
    feature = List<CategoryModel>.from(source.feature);
    area = source.area;
    location = source.location;
    minPrice = source.minPrice;
    maxPrice = source.maxPrice;
    color = source.color;
    sort = source.sort;
    startHour = source.startHour;
    endHour = source.endHour;
  }

  FilterModel clone() {
    return FilterModel.fromSource(this);
  }
}
