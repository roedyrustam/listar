import 'package:listar/models/model.dart';

abstract class BookingListState {}

class BookingListLoading extends BookingListState {}

class BookingListSuccess extends BookingListState {
  final List<BookingItemModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  BookingListSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}
