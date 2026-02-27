import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final String cardId;
  final double width;

  const PlayingCard({super.key, required this.cardId, this.width = 70});

  @override
  Widget build(BuildContext context) {
    if (cardId.isEmpty || cardId.length != 2) return const SizedBox();

    // Map our notation (Suit+Rank: HA) to API notation (Rank+Suit: AH)
    // Note: API uses '0' for Ten.
    final suit = cardId[0].toUpperCase();
    String rank = cardId[1].toUpperCase();
    if (rank == 'T') rank = '0';

    final imageUrl = 'https://deckofcardsapi.com/static/img/$rank$suit.png';

    return Container(
      width: width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.08),
        child: Image.network(
          imageUrl,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: width * 1.4,
              color: Colors.white,
              child: Center(
                child: Text(
                  cardId,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: width * 1.4,
              color: Colors.white10,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
