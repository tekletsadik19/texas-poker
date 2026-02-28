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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
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
            borderRadius: BorderRadius.circular(width * 0.1),
            child: Container(
              width: width,
              height: width * 1.4,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(width * 0.1),
                border: Border.all(
                  color: hasCard
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF30363D),
                  width: hasCard ? 2 : 1.5,
                ),
                boxShadow: hasCard
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: hasCard
                  ? PlayingCard(cardId: cardId!, width: width)
                  : Center(
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        color: const Color(0xFF30363D),
                        size: width * 0.4,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Color(0xFF484F58),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
