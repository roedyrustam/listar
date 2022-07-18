import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/repository/repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  int page = 1;
  List<ProductModel> listProduct = [];
  List<CommentModel> listComment = [];
  PaginationModel? pagination;
  UserModel? user;
  Timer? timer;

  void onLoad({
    required FilterModel filter,
    required String keyword,
    required int userID,
    required bool listing,
  }) async {
    page = 1;

    if (listing) {
      if (listProduct.isEmpty) {
        emit(ProfileLoading());
      }

      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        page: page,
        perPage: ListSetting.perPage,
        keyword: keyword,
        userID: userID,
        filter: filter,
      );
      if (result != null) {
        listProduct = result[0];
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.total);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      }
    } else {
      if (listComment.isEmpty) {
        emit(ProfileLoading());
      }

      ///Review Load
      final response = await ReviewRepository.loadAuthorReview(
        page: page,
        perPage: ListSetting.perPage,
        keyword: keyword,
        userID: userID,
      );
      if (response.success) {
        listComment = List.from(response.data ?? []).map((item) {
          return CommentModel.fromJson(item);
        }).toList();

        pagination = response.pagination;

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      } else {
        AppBloc.messageCubit.onShow(response.message);
      }
    }
  }

  void onSearch({
    required FilterModel filter,
    required String keyword,
    required int userID,
    required bool listing,
  }) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () async {
      page = 1;

      if (listing) {
        if (listProduct.isEmpty) {
          emit(ProfileLoading());
        }

        ///Listing Load
        final result = await ListRepository.loadAuthorList(
          page: page,
          perPage: ListSetting.perPage,
          keyword: keyword,
          userID: userID,
          filter: filter,
        );
        if (result != null) {
          listProduct = result[0];
          pagination = result[1];
          user = result[2];
          user!.updateUser(total: pagination!.total);

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listComment: listComment,
            canLoadMore: pagination!.page < pagination!.maxPage,
          ));
        }
      } else {
        if (listComment.isEmpty) {
          emit(ProfileLoading());
        }

        ///Review Load
        final response = await ReviewRepository.loadAuthorReview(
          page: page,
          perPage: ListSetting.perPage,
          keyword: keyword,
          userID: userID,
        );
        if (response.success) {
          listComment = List.from(response.data ?? []).map((item) {
            return CommentModel.fromJson(item);
          }).toList();

          pagination = response.pagination;

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listComment: listComment,
            canLoadMore: pagination!.page < pagination!.maxPage,
          ));
        } else {
          AppBloc.messageCubit.onShow(response.message);
        }
      }
    });
  }

  void onLoadMore({
    required FilterModel filter,
    required String keyword,
    required int userID,
    required bool listing,
  }) async {
    page += 1;

    ///Notify loading more

    emit(ProfileSuccess(
      user: user!,
      listProduct: listProduct,
      listComment: listComment,
      canLoadMore: pagination!.page < pagination!.maxPage,
      loadingMore: true,
    ));

    if (listing) {
      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        page: page,
        perPage: ListSetting.perPage,
        keyword: keyword,
        userID: userID,
        filter: filter,
      );
      if (result != null) {
        listProduct.addAll(result[0]);
        pagination = result[1];
        user = result[2];
        user!.updateUser(total: pagination!.total);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      }
    } else {
      ///Review Load
      final response = await ReviewRepository.loadAuthorReview(
        page: page,
        perPage: ListSetting.perPage,
        keyword: keyword,
        userID: userID,
      );
      if (response.success) {
        final moreList = List.from(response.data ?? []).map((item) {
          return CommentModel.fromJson(item);
        }).toList();

        listComment.addAll(moreList);
        pagination = response.pagination;

        ///Notify

        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      } else {
        AppBloc.messageCubit.onShow(response.message);
      }
    }
  }
}
