import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class BottomNavScaffold extends StatefulWidget {
  final Widget child;

  const BottomNavScaffold({super.key, required this.child});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _selectedIndex = 0;

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      'Home',
      CupertinoIcons.house,
      AppRoutes.home,
      CupertinoIcons.house_fill,
    ),
    _NavItemData(
      'Profile',
      CupertinoIcons.person,
      AppRoutes.profile,
      CupertinoIcons.person_solid,
    ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
    context.go(_navItems[index].route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route) {
        setState(() {
          _selectedIndex = i;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onItemTapped(0);
        }
      },
      child: DoubleBackToCloseWrapper(
        enabled: _selectedIndex == 0,
        child: DarkThemeAnnotatedRegion(
          child: Scaffold(
            backgroundColor: AppColor.white,
            body: widget.child,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                border: Border(
                  top: BorderSide(
                    color: AppColor.borderGrey.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: kBottomNavigationBarHeight - 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_navItems.length, (index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;

                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            child: InkWell(
                              onTap: () => _onItemTapped(index),
                              highlightColor: Colors.transparent,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Selection Indicator Line at Top
                                  Container(
                                    height: 2,
                                    width: context.screenWidth * 0.18,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.black
                                          : Colors.transparent,
                                      // borderRadius: const BorderRadius.only(
                                      //   bottomLeft: Radius.circular(2),
                                      //   bottomRight: Radius.circular(2),
                                      // ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 24,
                                    color: isSelected
                                        ? AppColor.black
                                        : AppColor.gray,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColor.black
                                          : AppColor.gray,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _NavItemData(this.label, this.icon, this.route, this.selectedIcon);
}
