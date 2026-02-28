import 'package:flutter/material.dart';
import 'playing_card.dart';
import 'card_selector.dart';

class VisualCardSlot extends StatelessWidget {
  final String? cardId;
  final String label;
  final ValueChanged<String?> onCardChanged;
  final double width;

  const VisualCardSlot({
    super.key,
    required this.cardId,
    required this.label,
    required this.onCardChanged,
    this.width = 60,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCard = cardId != null && cardId!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => const VisualCardSelector(),
        );
        if (result == 'CLEAR') {
          onCardChanged(null);
        } else if (result != null) {
          onCardChanged(result);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: width * 1.4,
            decoration: BoxDecoration(
              color: hasCard ? Colors.white : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(width * 0.12),
              border: hasCard
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    )
                  : Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
              boxShadow: hasCard
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: hasCard
                ? PlayingCard(cardId: cardId!, width: width)
                : Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: const Color(0xFFB0B4B8),
                      size: width * 0.4,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6E7681),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
