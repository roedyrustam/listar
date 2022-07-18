import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class Discovery extends StatefulWidget {
  const Discovery({Key? key}) : super(key: key);

  @override
  _DiscoveryState createState() {
    return _DiscoveryState();
  }
}

class _DiscoveryState extends State<Discovery> {
  late StreamSubscription _submitSubscription;

  @override
  void initState() {
    super.initState();
    AppBloc.discoveryCubit.onLoad();
    _submitSubscription = AppBloc.submitCubit.stream.listen((state) {
      if (state is Submitted) {
        _onRefresh();
      }
    });
  }

  @override
  void dispose() {
    _submitSubscription.cancel();
    super.dispose();
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await AppBloc.discoveryCubit.onLoad();
  }

  ///On search
  void _onSearch() {
    Navigator.pushNamed(context, Routes.searchHistory);
  }

  ///On navigate list product
  void _onProductList(CategoryModel item) {
    Navigator.pushNamed(
      context,
      Routes.listProduct,
      arguments: item,
    );
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: SizedBox(
                height: 48,
                child: InkWell(
                  onTap: _onSearch,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(.05),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                Translate.of(context).translate(
                                  'search_location',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .button!
                                    .copyWith(
                                        color: Theme.of(context).hintColor),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: VerticalDivider(),
                            ),
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                builder: (context, discovery) {
                  ///Loading
                  Widget content = SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return const AppDiscoveryItem();
                      },
                      childCount: 15,
                    ),
                  );

                  ///Success
                  if (discovery is DiscoverySuccess) {
                    if (discovery.list.isEmpty) {
                      content = SliverFillRemaining(
                        child: Center(
                          child: Text(
                            Translate.of(context).translate(
                              'can_not_found_data',
                            ),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      );
                    } else {
                      content = SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = discovery.list[index];
                            return AppDiscoveryItem(
                              item: item,
                              onSeeMore: _onProductList,
                              onProductDetail: _onProductDetail,
                            );
                          },
                          childCount: discovery.list.length,
                        ),
                      );
                    }
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      CupertinoSliverRefreshControl(
                        onRefresh: _onRefresh,
                      ),
                      SliverSafeArea(
                        top: false,
                        sliver: SliverPadding(
                          padding: const EdgeInsets.only(top: 8, bottom: 28),
                          sliver: content,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
