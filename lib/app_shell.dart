import 'package:flutter/material.dart';
import 'package:puzzle_arcade/library_screen.dart';

// Navigation Screens
enum NavigationItem {
  library,
  statistics,
  settings
}

// Main App Shell
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  var currentPage = NavigationItem.library;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = NavigationItem.values[index];
            });
          },
          selectedIndex: currentPage.index,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ], 
        ),

        body: <Widget>[
          // Library Page
          const LibraryScreen(),


          // Statistics Page
          Card(
            color: Colors.red[100],
            child: Center(
              child: Text('Statistics Page'),
            ),
          ),

          // Settings Page
          Card(
            color: Colors.green[100],
            child: Center(
              child: Text('Settings Page'),
            ),
          ),
        ][currentPage.index],
    );
  }
}