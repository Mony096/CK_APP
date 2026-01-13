import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_tokens.dart';

/// Platform-adaptive tab bar that uses Material TabBar on Android 
/// and CupertinoSlidingSegmentedControl on iOS
/// 
/// Usage:
/// ```dart
/// AdaptiveTabBar(
///   selectedIndex: _selectedIndex,
///   onTabChanged: (index) => setState(() => _selectedIndex = index),
///   tabs: [
///     AdaptiveTab(label: 'Tickets', icon: Icons.list),
///     AdaptiveTab(label: 'KPI', icon: Icons.bar_chart),
///   ],
/// )
/// ```
class AdaptiveTabBar extends StatelessWidget {
  const AdaptiveTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.tabs,
    this.isScrollable = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<AdaptiveTab> tabs;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildCupertinoTabBar(context);
    }
    return _buildMaterialTabBar(context);
  }

  Widget _buildMaterialTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.small,
      ),
      child: DefaultTabController(
        length: tabs.length,
        initialIndex: selectedIndex,
        child: TabBar(
          isScrollable: isScrollable,
          onTap: onTabChanged,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: tabs.map((tab) => Tab(
            text: tab.label,
            icon: tab.icon != null ? Icon(tab.icon, size: 20) : null,
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildCupertinoTabBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedIndex,
        onValueChanged: (value) {
          if (value != null) onTabChanged(value);
        },
        children: {
          for (int i = 0; i < tabs.length; i++)
            i: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tabs[i].icon != null) ...[
                    Icon(
                      tabs[i].icon,
                      size: 16,
                      color: selectedIndex == i 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selectedIndex == i 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}

/// Tab item for AdaptiveTabBar
class AdaptiveTab {
  const AdaptiveTab({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

/// Platform-adaptive bottom navigation bar
class AdaptiveBottomNavBar extends StatelessWidget {
  const AdaptiveBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<AdaptiveNavItem> items;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildCupertinoNavBar(context);
    }
    return _buildMaterialNavBar(context);
  }

  Widget _buildMaterialNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 70,
      destinations: items.map((item) => NavigationDestination(
        icon: Icon(item.icon, size: 24),
        selectedIcon: Icon(item.activeIcon ?? item.icon, size: 24, color: AppColors.primary),
        label: item.label,
      )).toList(),
    );
  }

  Widget _buildCupertinoNavBar(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      activeColor: AppColors.primary,
      inactiveColor: AppColors.textSecondary,
      iconSize: 24,
      items: items.map((item) => BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(item.icon),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(item.activeIcon ?? item.icon),
        ),
        label: item.label,
      )).toList(),
    );
  }
}

/// Navigation item for AdaptiveBottomNavBar
class AdaptiveNavItem {
  const AdaptiveNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

/// Platform-adaptive app bar
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        leading: leading,
        trailing: actions != null && actions!.isNotEmpty 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
        backgroundColor: backgroundColor ?? AppColors.primary,
      );
    }

    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Platform-adaptive refresh indicator
class AdaptiveRefreshIndicator extends StatelessWidget {
  const AdaptiveRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: child,
    );
  }
}
