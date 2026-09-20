import 'package:flutter/material.dart';

/// Section header widget for list sections
///
/// Usage:
/// ```dart
/// SectionHeader(
///   title: 'Popular Items',
///   onViewAllTap: () => print('View all tapped'),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAllTap;
  final String viewAllText;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAllTap,
    this.viewAllText = 'View All',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onViewAllTap != null)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal section with title and action
///
/// Usage:
/// ```dart
/// HorizontalSection(
///   title: 'Categories',
///   itemCount: categories.length,
///   itemBuilder: (context, index) => CategoryCard(category: categories[index]),
///   height: 100,
/// )
/// ```
class HorizontalSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double height;
  final double spacing;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;

  const HorizontalSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 120,
    this.spacing = 12,
    this.padding,
    this.controller,
    this.showViewAll = false,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: title,
              onViewAllTap: showViewAll ? onViewAllTap : null,
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}

/// Grid section with section header
///
/// Usage:
/// ```dart
/// GridSection(
///   title: 'Products',
///   itemCount: products.length,
///   itemBuilder: (context, index) => ProductCard(product: products[index]),
///   crossAxisCount: 2,
/// )
/// ```
class GridSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;

  const GridSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 0.75,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(title: title),
          ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ],
    );
  }
}
