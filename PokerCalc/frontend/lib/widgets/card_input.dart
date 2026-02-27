import 'package:flutter/material.dart';
import 'playing_card.dart';

class CardInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const CardInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'e.g. HA',
  });

  @override
  State<CardInput> createState() => _CardInputState();
}

class _CardInputState extends State<CardInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  bool _isValidCard(String text) {
    if (text.length != 2) return false;
    final suit = text[0].toUpperCase();
    final rank = text[1].toUpperCase();
    return 'HDCS'.contains(suit) && '23456789TJQKA'.contains(rank);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.trim();
    final isValid = _isValidCard(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: widget.controller,
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1E2A35),
                labelStyle: const TextStyle(
                  color: Color(0xFF8FA4BB),
                  fontSize: 13,
                ),
                hintStyle: const TextStyle(
                  color: Color(0xFF3D5166),
                  fontSize: 13,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2C3E50),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF27AE60),
                    width: 2,
                  ),
                ),
              ),
            ),
            if (isValid)
              Positioned(right: 8, child: PlayingCard(cardId: text, width: 30)),
          ],
        ),
      ],
    );
  }
}

class CardRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<String> labels;

  const CardRow({super.key, required this.controllers, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(controllers.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < controllers.length - 1 ? 8 : 0),
            child: CardInput(controller: controllers[i], label: labels[i]),
          ),
        );
      }),
    );
  }
}
