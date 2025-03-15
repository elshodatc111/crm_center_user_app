import 'package:crm_center_student/screen/home/home_page.dart';
import 'package:crm_center_student/screen/paymart/paymart_page.dart';
import 'package:crm_center_student/screen/profile/profile_page.dart';
import 'package:crm_center_student/screen/test/test_page.dart';
import 'package:crm_center_student/screen/video/video_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PaymartPage(),
    TestPage(),
    VideoPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Guruhlar"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "To'lovlar"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Testlar"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Kurslar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

