import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_tokens.dart';

/// Datos de un destino de la barra inferior.
class PetNavDestination {
  const PetNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge = false,
    this.isPrimary = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool badge;
  final bool isPrimary;
}

/// Barra inferior flotante (píldora) con botón central elevado.
/// Medidas del diseño: inset 14, bottom 18, alto 72, radio 26.
class PetNavBar extends StatelessWidget {
  const PetNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<PetNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? cs.surface.withValues(alpha: 0.94)
        : PetTokens.surface.withValues(alpha: 0.94);
    final borderColor = isDark ? cs.outline : const Color(0xFFEFE4DB);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PetTokens.navInset,
          0,
          PetTokens.navInset,
          PetTokens.navBottom,
        ),
        child: Container(
          height: PetTokens.navHeight,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PetTokens.rNav),
            border: Border.all(color: borderColor),
            boxShadow: PetTokens.shadowNav,
          ),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final PetNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? cs.primary : PetTokens.plum;
    final inactiveColor = isDark ? cs.onSurfaceVariant : PetTokens.muted2;
    final color = selected ? activeColor : inactiveColor;

    final label = Text(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: PetTokens.body(11, color: color, weight: FontWeight.w700),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: destination.isPrimary
              ? _buildPrimary(cs, label)
              : _buildRegular(color, activeColor, label),
        ),
      ),
    );
  }

  Widget _buildRegular(Color color, Color activeColor, Widget label) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, a) =>
                      ScaleTransition(scale: a, child: child),
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    key: ValueKey(selected),
                    size: 22,
                    color: color,
                  ),
                ),
                if (destination.badge)
                  Positioned(
                    top: -1,
                    right: -5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: PetTokens.clay,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PetTokens.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            label,
          ],
        ),
        Positioned(
          bottom: 2,
          child: AnimatedScale(
            scale: selected ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: PetTokens.bounce,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: PetTokens.clay,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimary(ColorScheme cs, Widget label) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -26,
          child: AnimatedScale(
            scale: selected ? 1.06 : 1,
            duration: const Duration(milliseconds: 220),
            curve: PetTokens.bounce,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: PetTokens.plum,
                borderRadius: BorderRadius.circular(PetTokens.rFab),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x594A2D4A),
                    offset: Offset(0, 10),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: const Icon(
                PhosphorIconsRegular.plus,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(bottom: 10, child: label),
      ],
    );
  }
}
