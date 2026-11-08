import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }

  /// A shimmering list view of items
  static Widget list({
    int itemCount = 5,
    double height = 72,
    double padding = 16,
    double borderRadius = 12,
  }) {
    return ShimmerLoading(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: padding),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: padding),
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  /// A shimmering grid view of items
  static Widget grid({
    int itemCount = 4,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    double spacing = 12,
  }) {
    return ShimmerLoading(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// A simple card/box shimmer skeleton
  static Widget card({
    double height = 150,
    double width = double.infinity,
    double borderRadius = 12,
  }) {
    return ShimmerLoading(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// A circular/avatar shimmer skeleton
  static Widget circle({double radius = 24}) {
    return ShimmerLoading(
      child: CircleAvatar(radius: radius, backgroundColor: Colors.white),
    );
  }

  /// A text-line shimmer skeleton
  static Widget line({
    double height = 14,
    double width = 100,
    double borderRadius = 4,
  }) {
    return ShimmerLoading(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
