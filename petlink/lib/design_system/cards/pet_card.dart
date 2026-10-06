import 'package:flutter/material.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';

class PetCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const PetCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: PetRadius.xlAll,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(PetSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
