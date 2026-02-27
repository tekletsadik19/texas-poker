import 'package:flutter/material.dart';

class CardInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 2,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFF1E2A35),
        labelStyle: const TextStyle(color: Color(0xFF8FA4BB)),
        hintStyle: const TextStyle(color: Color(0xFF3D5166)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF27AE60), width: 2),
        ),
      ),
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
