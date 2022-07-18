import 'package:bloc/bloc.dart';
import 'package:listar/blocs/app_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/repository/repository.dart';
import 'package:listar/utils/utils.dart';

enum LoginState {
  init,
  loading,
  success,
  fail,
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.init);

  void onLogin({
    required String username,
    required String password,
  }) async {
    ///Notify
    emit(LoginState.loading);

    ///Set Device Token
    Application.device?.token = await UtilOther.getDeviceToken();

    ///login via repository
    final result = await UserRepository.login(
      username: username,
      password: password,
    );

    if (result != null) {
      ///Begin start Auth flow
      await AppBloc.authenticateCubit.onSave(result);

      ///Notify
      emit(LoginState.success);
    } else {
      ///Notify
      emit(LoginState.fail);
    }
  }

  void onLogout() async {
    ///Begin start auth flow
    emit(LoginState.init);
    AppBloc.authenticateCubit.onClear();
  }
}
