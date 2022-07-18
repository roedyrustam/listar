import 'package:listar/models/model.dart';

abstract class CategoryState {}

class CategoryLoading extends CategoryState {}

class CategorySuccess extends CategoryState {
  final List<CategoryModel> list;
  CategorySuccess(this.list);
}
