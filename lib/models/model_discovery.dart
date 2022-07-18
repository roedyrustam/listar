import 'package:listar/models/model.dart';

class DiscoveryModel {
  final CategoryModel category;
  final List<ProductModel> list;

  DiscoveryModel({
    required this.category,
    required this.list,
  });

  factory DiscoveryModel.fromJson(Map<String, dynamic> json) {
    return DiscoveryModel(
      category: CategoryModel.fromJson(json),
      list: List.from(json['posts'] ?? []).map((e) {
        return ProductModel.fromJson(e);
      }).toList(),
    );
  }
}
