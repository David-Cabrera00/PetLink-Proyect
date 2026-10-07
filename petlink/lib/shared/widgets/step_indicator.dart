import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const StepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        final isCurrent = index == current - 1;
        final children = <Widget>[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: isActive || isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ];
        if (index < total - 1) {
          children.add(const SizedBox(width: 8));
        }
        return Expanded(child: Row(children: children));
      }),
    );
  }
}
