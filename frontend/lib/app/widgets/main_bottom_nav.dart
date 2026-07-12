import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final navC = Get.find<NavigationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.people_rounded, 'label': 'Konsultasi'},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chatbot'},
      {'icon': Icons.history_rounded, 'label': 'Riwayat'},
      {'icon': Icons.settings_rounded, 'label': 'Pengaturan'},
    ];

    return Obx(() {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Blur Glassmorphism
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.08) // Dark mode bg
                      : Colors.white.withOpacity(0.9), // Light mode bg
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.white.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(navItems.length, (index) {
                    final isSelected = navC.currentIndex.value == index;
                    
                    return _buildNavItem(
                      navC: navC,
                      item: navItems[index],
                      index: index,
                      isSelected: isSelected,
                      theme: theme,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required NavigationController navC,
    required Map<String, dynamic> item,
    required int index,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          HapticFeedback.lightImpact();
          navC.changePage(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16.0 : 12.0,
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.primaryColor.withOpacity(0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'],
                size: 22,
                color: isSelected 
                    ? theme.primaryColor 
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: isSelected ? 6.0 : 0),
                    child: Text(
                      item['label'],
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}