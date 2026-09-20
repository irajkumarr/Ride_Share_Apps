import 'package:flutter/material.dart';
import '../../../common/extensions/extensions.dart';
import '../../utils/colors.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final TabController controller;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.activeColor,
    this.inactiveColor,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = activeColor ?? AppColor.secondary;
    final unselectedColor = inactiveColor ?? AppColor.gray;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.borderGrey,
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2.0,
        indicatorColor: selectedColor,
        labelColor: selectedColor,
        unselectedLabelColor: unselectedColor,
        dividerColor: Colors
            .transparent, // Disable default flutter 3.10+ divider as we use custom bottom border
        labelStyle: context.textTheme.bodyLarge,
        unselectedLabelStyle: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

/* 
// ==========================================
// HOW TO USE THIS CUSTOM TAB BAR
// ==========================================

class _DemoScreenState extends State<DemoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Tab Bar Demo'),
      ),
      body: Column(
        children: [
          CustomTabBar(
            tabs: const ['Ongoing', 'Completed', 'Cancelled'],
            controller: _tabController,
            // activeColor: AppColor.secondary,   // Optional
            // inactiveColor: AppColor.gray,      // Optional
            // isScrollable: false,               // Optional
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: Text("Ongoing Activities")),
                Center(child: Text("Completed Activities")),
                Center(child: Text("Cancelled Activities")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
