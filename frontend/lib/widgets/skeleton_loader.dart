import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dark Theme Skeleton Loader with Smooth Shimmer Effect
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.radiusSm,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _gradientAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_gradientAnimation.value - 1, 0),
              end: Alignment(_gradientAnimation.value + 1, 0),
              colors: const [
                Color(0xFF131D2E),
                Color(0xFF1E2E4A),
                Color(0xFF131D2E),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built Skeleton Card for Bus Loading States
class BusCardSkeleton extends StatelessWidget {
  const BusCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(border: AppTheme.borderSubtle),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SkeletonLoader(width: 38, height: 38, borderRadius: AppTheme.radiusMd),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 85, height: 16),
                      SizedBox(height: 6),
                      SkeletonLoader(width: 130, height: 12),
                    ],
                  ),
                ],
              ),
              SkeletonLoader(width: 65, height: 24, borderRadius: AppTheme.radiusPill),
            ],
          ),
          SizedBox(height: 14),
          SkeletonLoader(width: double.infinity, height: 38, borderRadius: AppTheme.radiusMd),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 44, borderRadius: AppTheme.radiusMd),
        ],
      ),
    );
  }
}

/// Pre-built Skeleton Card for Route Loading States
class RouteCardSkeleton extends StatelessWidget {
  const RouteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(border: AppTheme.borderSubtle),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SkeletonLoader(width: 38, height: 38, borderRadius: AppTheme.radiusMd),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 75, height: 16),
                      SizedBox(height: 6),
                      SkeletonLoader(width: 120, height: 12),
                    ],
                  ),
                ],
              ),
              SkeletonLoader(width: 70, height: 24, borderRadius: AppTheme.radiusPill),
            ],
          ),
          SizedBox(height: 14),
          SkeletonLoader(width: double.infinity, height: 38, borderRadius: AppTheme.radiusMd),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 44, borderRadius: AppTheme.radiusMd),
        ],
      ),
    );
  }
}
