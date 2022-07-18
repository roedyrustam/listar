import 'package:bloc/bloc.dart';
import 'package:listar/models/model.dart';
import 'package:listar/repository/repository.dart';

import 'cubit.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryLoading());
  List<CategoryModel> list = [];

  Future<void> onLoad(String keyword) async {
    if (keyword.isEmpty) {
      final result = await CategoryRepository.loadCategory();
      if (result != null) {
        list = result;
      }

      ///Notify
      emit(CategorySuccess(list.where((item) {
        return item.title.toUpperCase().contains(keyword.toUpperCase());
      }).toList()));
    } else {
      if (list.isEmpty) {
        final result = await CategoryRepository.loadCategory();
        if (result != null) {
          list = result;
        }
      }

      ///Notify
      emit(CategorySuccess(list.where((item) {
        return item.title.toUpperCase().contains(keyword.toUpperCase());
      }).toList()));
    }
  }
}
