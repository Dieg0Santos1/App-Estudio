import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class FocusBottomNav extends StatelessWidget {
  const FocusBottomNav({required this.currentRoute, super.key});

  final AppRoute currentRoute;

  static const _items = [
    _NavItem(AppRoute.library, Icons.folder_open_rounded, 'Biblioteca'),
    _NavItem(AppRoute.studySession, Icons.view_timeline_rounded, 'Sesiones'),
    _NavItem(AppRoute.home, Icons.home_rounded, 'Inicio'),
    _NavItem(AppRoute.progress, Icons.trending_up_rounded, 'Progreso'),
    _NavItem(AppRoute.profile, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF09223D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF174D75)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            for (final item in _items)
              Expanded(
                child: _BottomNavButton(
                  item: item,
                  isSelected: item.route == currentRoute,
                  onTap: () {
                    if (item.route != currentRoute) {
                      context.go(item.route.path);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.route, this.icon, this.label);

  final AppRoute route;
  final IconData icon;
  final String label;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF062033) : Colors.transparent;
    final iconColor = isSelected ? Colors.white : const Color(0xFFB8CAE0);
    final labelColor = isSelected
        ? const Color(0xFFE9FBFF)
        : const Color(0xFFB8CAE0);
    final isCenter = item.route == AppRoute.home;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isCenter ? 34 : 28,
                height: isCenter ? 30 : 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF21C7B7)
                      : color.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: isCenter && !isSelected
                      ? Border.all(color: const Color(0xFF1E5A7B))
                      : null,
                ),
                child: Icon(
                  item.icon,
                  color: iconColor,
                  size: isCenter ? 20 : 18,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
