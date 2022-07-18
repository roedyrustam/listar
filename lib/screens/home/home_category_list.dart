import 'package:flutter/material.dart';
import 'package:listar/models/model.dart';
import 'package:listar/screens/home/home_category_item.dart';
import 'package:listar/utils/utils.dart';

class HomeCategoryList extends StatelessWidget {
  final List<CategoryModel>? list;
  final Function(CategoryModel)? onPress;
  final VoidCallback? onOpenList;

  const HomeCategoryList({
    Key? key,
    this.list,
    this.onPress,
    this.onOpenList,
  }) : super(key: key);

  Widget _buildContent(List<CategoryModel>? list) {
    if (list != null) {
      return Wrap(
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: list.map(
          (item) {
            return HomeCategoryItem(
              item: item,
              onPressed: onPress,
            );
          },
        ).toList(),
      );
    }

    ///Loading
    return Wrap(
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(8, (index) => index).map(
        (item) {
          return const HomeCategoryItem();
        },
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translate.of(context).translate('explore_product'),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: onOpenList,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          Translate.of(context).translate('view_list'),
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: <Widget>[
                    _buildContent(list),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
