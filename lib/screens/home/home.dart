import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/screens/home/home_category_item.dart';
import 'package:listar/screens/home/home_category_list.dart';
import 'package:listar/screens/home/home_sliver_app_bar.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  late StreamSubscription _submitSubscription;
  late StreamSubscription _reviewSubscription;

  @override
  void initState() {
    super.initState();
    AppBloc.homeCubit.onLoad();
    _submitSubscription = AppBloc.submitCubit.stream.listen((state) {
      if (state is Submitted) {
        AppBloc.homeCubit.onLoad();
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewSuccess && state.id != null) {
        AppBloc.homeCubit.onLoad();
      }
    });
  }

  @override
  void dispose() {
    _submitSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }

  ///Refresh
  Future<void> _onRefresh() async {
    await AppBloc.homeCubit.onLoad();
  }

  ///On search
  void _onSearch() {
    Navigator.pushNamed(context, Routes.searchHistory);
  }

  ///On select category
  void _onTapService(CategoryModel item) {
    Navigator.pushNamed(context, Routes.listProduct, arguments: item);
  }

  ///On Open More
  void _onOpenMore(
    BuildContext context, {
    List<CategoryModel>? category,
  }) async {
    final result = await showModalBottomSheet<CategoryModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return HomeCategoryList(
          list: category,
          onOpenList: () {
            Navigator.pushNamed(context, Routes.category);
          },
          onPress: (item) {
            Navigator.pop(context, item);
          },
        );
      },
    );
    if (result != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pushNamed(context, Routes.listProduct, arguments: result);
    }
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item.id);
  }

  ///Build category UI
  Widget _buildCategory(List<CategoryModel>? category) {
    ///Loading
    Widget content = Wrap(
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(8, (index) => index).map(
        (item) {
          return const HomeCategoryItem();
        },
      ).toList(),
    );

    if (category != null) {
      List<CategoryModel> listBuild = category;
      final more = CategoryModel.fromJson({
        "term_id": -1,
        "name": Translate.of(context).translate("more"),
        "icon": "fas fa-ellipsis-h",
        "color": "#ff8a65",
      });

      if (category.length >= 7) {
        listBuild = category.take(7).toList();
        listBuild.add(more);
      }

      content = Wrap(
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: listBuild.map(
          (item) {
            return HomeCategoryItem(
              item: item,
              onPressed: (item) {
                if (item.id == -1) {
                  _onOpenMore(context, category: listBuild);
                } else {
                  _onTapService(item);
                }
              },
            );
          },
        ).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }

  ///Build popular UI
  Widget _buildLocation(List<CategoryModel>? location) {
    ///Loading
    Widget content = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: AppCategory(
            type: CategoryView.cardLarge,
          ),
        );
      },
      itemCount: List.generate(8, (index) => index).length,
    );

    if (location != null) {
      content = ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = location[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AppCategory(
              item: item,
              type: CategoryView.cardLarge,
              onPressed: () {
                _onTapService(item);
              },
            ),
          );
        },
        itemCount: location.length,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translate.of(context).translate(
                  'popular_location',
                ),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                Translate.of(context).translate(
                  'let_find_interesting',
                ),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
        Container(
          height: 195,
          padding: const EdgeInsets.only(top: 4),
          child: content,
        ),
      ],
    );
  }

  ///Build list recent
  Widget _buildRecent(List<ProductModel>? recent) {
    ///Loading
    Widget content = ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: AppProductItem(type: ProductViewType.small),
        );
      },
      itemCount: 8,
    );

    if (recent != null) {
      content = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = recent[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppProductItem(
              onPressed: () {
                _onProductDetail(item);
              },
              item: item,
              type: ProductViewType.small,
            ),
          );
        },
        itemCount: recent.length,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate('recent_location'),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  Translate.of(context).translate(
                    'what_happen',
                  ),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: content,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          List<String>? banner;
          List<CategoryModel>? category;
          List<CategoryModel>? location;
          List<ProductModel>? recent;

          if (state is HomeSuccess) {
            banner = state.banner;
            category = state.category;
            location = state.location;
            recent = state.recent;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPersistentHeader(
                delegate: AppBarHomeSliver(
                  expandedHeight: 250,
                  banners: banner,
                  onSearch: _onSearch,
                ),
                pinned: true,
              ),
              CupertinoSliverRefreshControl(
                onRefresh: _onRefresh,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      children: <Widget>[
                        _buildCategory(category),
                        _buildLocation(location),
                        _buildRecent(recent),
                        const SizedBox(height: 28),
                      ],
                    ),
                  )
                ]),
              )
            ],
          );
        },
      ),
    );
  }
}
