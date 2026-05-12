import 'package:flutter/material.dart';
import '../views/auth/login_page.dart';
import '../views/layout/admin_layout.dart';
import '../controllers/auth_controller.dart';

class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey;
  final AuthController authController;
  String _currentPath = "/login";
  AppRouterDelegate(this.authController)
    : navigatorKey = GlobalKey<NavigatorState>() {
    authController.addListener(notifyListeners);
  }
  @override
  String? get currentConfiguration => _currentPath;
  @override
  Widget build(BuildContext context) {
    if (!authController.isLoggedIn) {
      return Navigator(
        key: navigatorKey,
        pages: const [MaterialPage(child: LoginPage())],
        onPopPage: (route, result) => route.didPop(result),
      );
    }
    Widget page;
    switch (_currentPath) {
      default:
        page = const Center(child: Text("Dashboard Page"));
    }
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          child: AdminLayout(
            currentRoute: _currentPath, // truyền route hiện tại
            onNavigate: (path) {
              _currentPath = path;
              notifyListeners();
            },
            child: page,
          ),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _currentPath = configuration;
  }
}

class AppRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation.location ?? "/login";
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
