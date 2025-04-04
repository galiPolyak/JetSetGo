import 'package:flutter/material.dart';
import 'package:jetsetgo/pages/home_page.dart'; 
import 'package:jetsetgo/pages/profile_page.dart'; 

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 0) {
          //Going to  HomePage directly when Home icon is tapped
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), //always go to HomePage
          );
        } else if (index == 1) {
          // ProfilePage when Profile icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()), //navigate to ProfilePage
          );
        }
      },
      backgroundColor: const Color(0xFF2C2C2E), 
      selectedItemColor: const Color(0xFFD76C5B), // coral when active
      unselectedItemColor: Color(0xFFFBE8D2), // peach !!!
      selectedFontSize: 14,
      unselectedFontSize: 13,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), 
          label: 'Profile',
        ),
      ],
    );
  }
}
