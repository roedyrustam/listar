import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/screens/screen.dart';
import 'package:listar/utils/utils.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() {
    return _AppContainerState();
  }
}

class _AppContainerState extends State<AppContainer> {
  String _selected = Routes.home;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
      _notificationHandle(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _notificationHandle(message);
    });
  }

  ///check route need auth
  bool _requireAuth(String route) {
    switch (route) {
      case Routes.home:
      case Routes.discovery:
        return false;
      default:
        return true;
    }
  }

  ///Export index stack
  int _exportIndexed(String route) {
    switch (route) {
      case Routes.home:
        return 0;
      case Routes.discovery:
        return 1;
      case Routes.wishList:
        return 2;
      case Routes.account:
        return 3;
      default:
        return 0;
    }
  }

  ///Handle When Press Notification
  void _notificationHandle(RemoteMessage message) {
    final notification = NotificationModel.fromRemoteMessage(message);
    switch (notification.action) {
      case NotificationAction.created:
        Navigator.pushNamed(
          context,
          Routes.productDetail,
          arguments: notification.id,
        );
        return;

      default:
        return;
    }
  }

  ///Force switch home when authentication state change
  void _listenAuthenticateChange(AuthenticationState authentication) async {
    if (authentication == AuthenticationState.fail && _requireAuth(_selected)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: _selected,
      );
      if (result != null) {
        setState(() {
          _selected = result as String;
        });
      } else {
        setState(() {
          _selected = Routes.home;
        });
      }
    }
  }

  ///On change tab bottom menu and handle when not yet authenticate
  void _onItemTapped({
    required String route,
    required bool authenticated,
  }) async {
    if (!authenticated && _requireAuth(route)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: route,
      );
      if (result == null) return;
    }
    setState(() {
      _selected = route;
    });
  }

  ///On handle submit post
  void _onSubmit(bool authenticated) async {
    if (!authenticated) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.submit,
      );
      if (result == null) return;
    }
    Navigator.pushNamed(context, Routes.submit);
  }

  ///Build Item Menu
  Widget _buildMenuItem({
    required String route,
    required bool authenticated,
  }) {
    Color? color;
    String title = 'home';
    IconData iconData = Icons.help_outline;
    switch (route) {
      case Routes.home:
        iconData = Icons.home_outlined;
        title = 'home';
        break;
      case Routes.discovery:
        iconData = Icons.location_on_outlined;
        title = 'discovery';
        break;
      case Routes.wishList:
        iconData = Icons.bookmark_outline;
        title = 'wish_list';
        break;
      case Routes.account:
        iconData = Icons.account_circle_outlined;
        title = 'account';
        break;
      default:
        iconData = Icons.home_outlined;
        title = 'home';
        break;
    }
    if (route == _selected) {
      color = Theme.of(context).primaryColor;
    }
    return IconButton(
      onPressed: () {
        _onItemTapped(route: route, authenticated: authenticated);
      },
      padding: EdgeInsets.zero,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            Translate.of(context).translate(title),
            style: Theme.of(context).textTheme.button!.copyWith(
                  fontSize: 10,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, authentication) async {
        _listenAuthenticateChange(authentication);
      },
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, authentication) {
          final authenticated = authentication != AuthenticationState.fail;
          return Scaffold(
            body: IndexedStack(
              index: _exportIndexed(_selected),
              children: const <Widget>[
                Home(),
                Discovery(),
                WishList(),
                Account()
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMenuItem(
                      route: Routes.home,
                      authenticated: authenticated,
                    ),
                    _buildMenuItem(
                      route: Routes.discovery,
                      authenticated: authenticated,
                    ),
                    const SizedBox(width: 56),
                    _buildMenuItem(
                      route: Routes.wishList,
                      authenticated: authenticated,
                    ),
                    _buildMenuItem(
                      route: Routes.account,
                      authenticated: authenticated,
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                _onSubmit(authenticated);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }
}
