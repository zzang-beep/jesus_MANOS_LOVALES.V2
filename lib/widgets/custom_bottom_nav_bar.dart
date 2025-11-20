import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _navItem({
    required int index,
    required String icon,
    required String selectedIcon,
  }) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Image.asset(
          isSelected ? selectedIcon : icon,
          width: isSelected ? 36 : 28,
          height: isSelected ? 36 : 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            index: 0,
            icon: "assets/images/home.png",
            selectedIcon: "assets/images/home_selected.png",
          ),
          _navItem(
            index: 1,
            icon: "assets/images/chat.png",
            selectedIcon: "assets/images/chat_selected.png",
          ),
          _navItem(
            index: 2,
            icon: "assets/images/search.png",
            selectedIcon: "assets/images/search_selected.png",
          ),
          _navItem(
            index: 3,
            icon: "assets/images/profile.png",
            selectedIcon: "assets/images/profile_selected.png",
          ),
        ],
      ),
    );
  }
}
