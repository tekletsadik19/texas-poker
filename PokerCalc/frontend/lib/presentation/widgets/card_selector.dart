import 'package:flutter/material.dart';

class VisualCardSelector extends StatefulWidget {
  const VisualCardSelector({super.key});

  @override
  State<VisualCardSelector> createState() => _VisualCardSelectorState();
}

class _VisualCardSelectorState extends State<VisualCardSelector> {
  String? selectedSuit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE1E4E8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECT A CARD',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  'S',
                  'H',
                  'D',
                  'C',
                ].map((s) => _suitIcon(s)).toList(),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  'A',
                  'K',
                  'Q',
                  'J',
                  'T',
                  '9',
                  '8',
                  '7',
                  '6',
                  '5',
                  '4',
                  '3',
                  '2',
                ].map((r) => _rankChip(r)).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'CLEAR'),
                    child: const Text(
                      'CLEAR SLOT',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE1E4E8),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suitIcon(String s) {
    final bool isSel = selectedSuit == s;
    final Color color = s == 'H' || s == 'D' ? Colors.red : Colors.black;
    return GestureDetector(
      onTap: () => setState(() => selectedSuit = s),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(_getEmoji(s), style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  Widget _rankChip(String r) {
    return InkWell(
      onTap: () {
        if (selectedSuit != null) {
          Navigator.pop(context, '$selectedSuit$r');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pick a suit first!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E4E8)),
        ),
        child: Center(
          child: Text(
            r,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }

  String _getEmoji(String s) {
    switch (s) {
      case 'S':
        return '♠️';
      case 'H':
        return '♥️';
      case 'D':
        return '♦️';
      case 'C':
        return '♣️';
      default:
        return '';
    }
  }
}
