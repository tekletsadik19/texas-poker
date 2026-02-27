import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final String card;
  final double width;
  final double height;

  const PlayingCard({
    super.key,
    required this.card,
    this.width = 60,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    if (card.length != 2) return SizedBox(width: width, height: height);

    final suit = card[0].toUpperCase();
    final rank = card[1].toUpperCase();

    Color suitColor;
    String suitSymbol;

    switch (suit) {
      case 'H':
        suitColor = const Color(0xFFE74C3C);
        suitSymbol = '♥';
        break;
      case 'D':
        suitColor = const Color(0xFFE74C3C);
        suitSymbol = '♦';
        break;
      case 'S':
        suitColor = const Color(0xFF2C3E50);
        suitSymbol = '♠';
        break;
      case 'C':
        suitColor = const Color(0xFF2C3E50);
        suitSymbol = '♣';
        break;
      default:
        suitColor = Colors.grey;
        suitSymbol = '?';
    }

    String displayRank = rank;
    if (rank == 'T') displayRank = '10';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Stack(
        children: [
          // Top Left Rank
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayRank,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  suitSymbol,
                  style: TextStyle(color: suitColor, fontSize: 12, height: 1),
                ),
              ],
            ),
          ),

          // Center Huge Suit
          Center(
            child: Text(
              suitSymbol,
              style: TextStyle(
                color: suitColor.withOpacity(0.15),
                fontSize: height * 0.6,
                height: 1,
              ),
            ),
          ),

          // Bottom Right Rank (inverted)
          Positioned(
            bottom: 4,
            right: 4,
            child: RotatedBox(
              quarterTurns: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayRank,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(color: suitColor, fontSize: 12, height: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
