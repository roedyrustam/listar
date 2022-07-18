import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class BookingList extends StatefulWidget {
  const BookingList({Key? key}) : super(key: key);

  @override
  _BookingListState createState() {
    return _BookingListState();
  }
}

class _BookingListState extends State<BookingList> {
  final _bookingList = BookingListCubit();
  final _textSearchController = TextEditingController();
  final _scrollController = ScrollController();
  final _endReachedThreshold = 100;

  Timer? _timer;
  SortModel? _sort;
  SortModel? _status;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _bookingList.close();
    _textSearchController.clear();
    super.dispose();
  }

  ///On Refresh List
  Future<void> _onRefresh() async {
    return await _bookingList.onLoad(
      sort: _sort,
      status: _status,
      keyword: _textSearchController.text,
    );
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _bookingList.state;
    if (state is BookingListSuccess &&
        state.canLoadMore &&
        !state.loadingMore) {
      _bookingList.onLoadMore(
        sort: _sort,
        status: _status,
        keyword: _textSearchController.text,
      );
    }
  }

  ///On Search
  void _onSearch(String? keyword) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      _bookingList.onLoad(
        sort: _sort,
        status: _status,
        keyword: keyword,
      );
    });
  }

  ///On Sort
  void _onSort() async {
    if (_bookingList.sortOption.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_sort],
            data: _bookingList.sortOption,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _sort = result;
      });
      _onRefresh();
    }
  }

  ///On Filter
  void _onFilter() async {
    if (_bookingList.statusOption.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_status],
            data: _bookingList.statusOption,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _status = result;
      });
      _onRefresh();
    }
  }

  ///On Detail Booking
  void _onDetail(int id) {
    Navigator.pushNamed(
      context,
      Routes.bookingDetail,
      arguments: RouteArguments(
        item: id,
        callback: _onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('my_booking')),
      ),
      body: BlocBuilder<BookingListCubit, BookingListState>(
        bloc: _bookingList,
        builder: (context, state) {
          Widget content = ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              return const AppBookingItem();
            },
            itemCount: 15,
          );
          if (state is BookingListSuccess) {
            if (state.list.isEmpty) {
              content = Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.sentiment_satisfied),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        Translate.of(context).translate(
                          'data_not_found',
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              int count = state.list.length;
              if (state.loadingMore) {
                count = count + 1;
              }
              content = ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                itemBuilder: (context, index) {
                  ///Loading loadMore item
                  if (index == state.list.length) {
                    return const AppBookingItem();
                  }
                  final item = state.list[index];
                  return AppBookingItem(
                    item: item,
                    onPressed: () {
                      _onDetail(item.id);
                    },
                  );
                },
                itemCount: count,
              );
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AppTextInput(
                    hintText: Translate.of(context).translate('search'),
                    controller: _textSearchController,
                    onChanged: _onSearch,
                    onSubmitted: _onSearch,
                    trailing: GestureDetector(
                      dragStartBehavior: DragStartBehavior.down,
                      onTap: () {
                        _textSearchController.clear();
                        _onSearch(null);
                      },
                      child: const Icon(Icons.clear),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: _onFilter,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.track_changes_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('filter'),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _onSort,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sort_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('sort'),
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: RefreshIndicator(
                      child: content,
                      onRefresh: _onRefresh,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
