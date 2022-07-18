import 'package:listar/models/model.dart';

abstract class BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailSuccess extends BookingDetailState {
  final BookingItemModel item;
  BookingDetailSuccess(this.item);
}
