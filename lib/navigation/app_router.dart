import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/list_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.fullPath.toString()),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/list');
                    break;
                  case 2:
                    context.go('/settings');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.white70,
              backgroundColor: Colors.black,
            ),
            body: child, // Nội dung trang con
          );
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => WaterQualityScreen()),
          GoRoute(
            path: '/list',
            builder: (context, state) => MonitoringListScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  // Hàm xác định index của bottom navigation bar dựa trên đường dẫn (URL)
  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/list')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }
}
