import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/search_screen.dart';

/// Premium Global Search Bar entry widget for the Home Dashboard
class GlobalSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool isReadOnly;

  const GlobalSearchBar({
    super.key,
    this.hintText = 'Search buses, routes or stops...',
    this.onTap,
    this.isReadOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open global search',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('global_search_bar_button'),
          onTap: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLayer1,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.borderMedium, width: 1),
              boxShadow: AppTheme.shadowSubtle,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primaryBlueLight,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    hintText,
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space8,
                    vertical: AppTheme.space2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLayer2,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Text(
                    'Ctrl K',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
