import 'package:flutter/material.dart';
import 'package:listar/screens/home/home_swiper.dart';
import 'package:listar/utils/utils.dart';

class AppBarHomeSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final List<String>? banners;
  final VoidCallback onSearch;

  AppBarHomeSliver({
    required this.expandedHeight,
    required this.onSearch,
    this.banners,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        HomeSwipe(
          images: banners,
          height: expandedHeight,
        ),
        Container(
          height: 36,
          color: Theme.of(context).backgroundColor,
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Card(
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: TextButton(
                onPressed: onSearch,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(.07),
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
                                  .copyWith(color: Theme.of(context).hintColor),
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
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
