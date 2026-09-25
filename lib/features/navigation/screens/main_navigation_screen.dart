import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/auth/screens/auth_screen.dart';
import 'package:pulze_plus/features/chat/screens/chats_screen.dart';
import 'package:pulze_plus/features/home/screens/home_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_form_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_screen.dart';
import 'package:pulze_plus/features/requests/screens/requests_screen.dart';
import 'package:pulze_plus/features/requests/widgets/create_blood_request_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../providers/navigation_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final authState = ref.watch(authProvider);

    final screens = [
      const HomeScreen(
        isGuest: false,
      ),
      const RequestsScreen(),
      const SizedBox.shrink(),
      ChatsScreen(
        onChatTap: (chat) {
          context.push(
            AppRoutes.chatDetail,
            extra: chat,
          );
        },
      ),
      _buildProfileScreen(authState),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _BottomNavigation(
        currentIndex: currentIndex,
        onItemSelected: (index) {
          ref
              .read(navigationIndexProvider.notifier)
              .setIndex(index);
        },
      ),
    );
  }

  Widget _buildProfileScreen(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return const ProfileScreen();

      case AuthStatus.needsProfile:
        return const ProfileFormScreen(
          mode: ProfileFormMode.create,
        );

      case AuthStatus.unauthenticated:
      case AuthStatus.needsVerification:
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const AuthScreen();
    }
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  void _openCreateBloodRequest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) {
        return CreateBloodRequestSheet(
          onCreate: () {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Blood request created successfully.',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        bottomPadding + AppSpacing.sm,
      ),
      child: SizedBox(
        height: 76,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: _NavigationDock(
                currentIndex: currentIndex,
                onItemSelected: onItemSelected,
              ),
            ),
            Positioned(
              top: -22,
              child: _CreateButton(
                onTap: () {
                  _openCreateBloodRequest(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDock extends StatelessWidget {
  const _NavigationDock({
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavigationItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onItemSelected(0),
            ),
          ),
          Expanded(
            child: _NavigationItem(
              icon: Icons.bloodtype_outlined,
              selectedIcon: Icons.bloodtype_rounded,
              label: 'Requests',
              selected: currentIndex == 1,
              onTap: () => onItemSelected(1),
            ),
          ),

          // Space reserved for floating Create button.
          const SizedBox(width: 64),

          Expanded(
            child: _NavigationItem(
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble_rounded,
              label: 'Chats',
              selected: currentIndex == 3,
              onTap: () => onItemSelected(3),
            ),
          ),
          Expanded(
            child: _NavigationItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              selected: currentIndex == 4,
              onTap: () => onItemSelected(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primary
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.05 : 1,
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontSize: 11,
                      height: 16 / 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeOutCubic,
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .surface,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 31,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}