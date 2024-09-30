import 'package:flutter/material.dart';
import 'package:kakaollama/src/utils/build_context_extension.dart';

class DummyImage extends StatelessWidget {
  const DummyImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      // TODO: Replace by an image 40x40
      child: Icon(
        Icons.person_outline_rounded,
        size: 28,
        color: context.color.onSurfaceVariant,
      ),
    );
  }
}
