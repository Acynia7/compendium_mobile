import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../theme/colors.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: BottomNavigationBar(
        key: ValueKey<int>(currentIndex), // Ensure the animation triggers on index change
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(
                context,
                '/contribute',
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                '/profile',
              );
              break;
          }
        },
        backgroundColor: colors.cardColor,
        selectedItemColor: colors.buttonColor,
        unselectedItemColor: colors.buttonColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ios_share),
            label: 'Contribuer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}