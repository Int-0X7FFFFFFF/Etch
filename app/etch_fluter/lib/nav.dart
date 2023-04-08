import 'package:flutter/material.dart';
import 'Gcode/g_code_page.dart';
import 'draw/draw_page.dart';

var _controller = PageController(
  initialPage: 0,
);

int _selectedIndex = 0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: const <Widget>[
          GcodePage(),
          DrawPage(),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    setState(() {
      _controller.jumpToPage(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.code),
          label: 'Gcode',
        ),
        NavigationDestination(
          icon: Icon(Icons.draw),
          label: 'Draw',
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
    );
  }
}
