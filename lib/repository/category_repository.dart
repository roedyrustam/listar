import 'package:listar/api/api.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/models/model.dart';

class CategoryRepository {
  ///Load Category
  static Future<List<CategoryModel>?> loadCategory() async {
    final result = await Api.requestCategory();
    if (result.success) {
      return List.from(result.data ?? []).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }

  ///Load Location category
  static Future<List<CategoryModel>?> loadLocation(int id) async {
    final result = await Api.requestLocation({"parent_id": id});
    if (result.success) {
      return List.from(result.data ?? []).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }

  ///Load Discovery
  static Future<List<DiscoveryModel>?> loadDiscovery() async {
    final result = await Api.requestDiscovery();
    if (result.success) {
      return List.from(result.data ?? []).map((item) {
        return DiscoveryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }
}
