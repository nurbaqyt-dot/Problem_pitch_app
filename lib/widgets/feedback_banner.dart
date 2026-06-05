import 'package:flutter/material.dart';

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.message,
  });

  final bool isCorrect;
  final String message;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCorrect
        ? const Color(0xFFE6F8EC)
        : const Color(0xFFFFE8E6);
    final accentColor = isCorrect
        ? const Color(0xFF1F9D53)
        : const Color(0xFFE15D4A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF17321E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
