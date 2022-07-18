import 'package:bloc/bloc.dart';
import 'package:listar/repository/repository.dart';

import 'cubit.dart';

class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit() : super(BookingDetailLoading());

  void onLoad(id) async {
    final result = await BookingRepository.loadDetail(id);
    if (result != null) {
      emit(BookingDetailSuccess(result));
    }
  }

  Future<void> onCancel(id) async {
    final result = await BookingRepository.cancel(id);
    if (result != null) {
      emit(BookingDetailSuccess(result));
    }
  }
}
