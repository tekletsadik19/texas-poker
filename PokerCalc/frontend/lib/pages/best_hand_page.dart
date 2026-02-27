import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/card_input.dart';

class BestHandPage extends StatefulWidget {
  const BestHandPage({super.key});

  @override
  State<BestHandPage> createState() => _BestHandPageState();
}

class _BestHandPageState extends State<BestHandPage> {
  final List<TextEditingController> _hole = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _comm = List.generate(
    5,
    (_) => TextEditingController(),
  );

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    for (final c in [..._hole, ..._comm]) c.dispose();
    super.dispose();
  }

  Future<void> _evaluate() async {
    final hole = _hole.map((c) => c.text.trim().toUpperCase()).toList();
    final comm = _comm.map((c) => c.text.trim().toUpperCase()).toList();

    if (hole.any((c) => c.length != 2) || comm.any((c) => c.length != 2)) {
      setState(
        () => _error = 'All cards must be 2 characters (e.g. HA, S7, CT)',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ApiClient.bestHand(hole, comm);
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Hole Cards'),
          const SizedBox(height: 10),
          CardRow(controllers: _hole, labels: ['Hole 1', 'Hole 2']),
          const SizedBox(height: 20),
          _sectionLabel('Community Cards'),
          const SizedBox(height: 10),
          CardRow(
            controllers: _comm.sublist(0, 3),
            labels: ['Flop 1', 'Flop 2', 'Flop 3'],
          ),
          const SizedBox(height: 10),
          CardRow(controllers: _comm.sublist(3), labels: ['Turn', 'River']),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _evaluate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Evaluate Best Hand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _errorCard(_error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            _resultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF8FA4BB),
      letterSpacing: 1.2,
    ),
  );

  Widget _errorCard(String error) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF2A1515),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE74C3C), width: 1.5),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(error, style: const TextStyle(color: Color(0xFFE74C3C))),
        ),
      ],
    ),
  );

  Widget _resultCard(Map<String, dynamic> result) {
    final cards = List<String>.from(result['best_cards'] ?? []);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2F1F), Color(0xFF152A1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF27AE60).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFF1C40F),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                result['rank_name'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1C40F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cards.map((c) => _cardChip(c)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _cardChip(String card) {
    final suit = card.isNotEmpty ? card[0] : '';
    final isRed = suit == 'H' || suit == 'D';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRed
              ? const Color(0xFFE74C3C).withOpacity(0.6)
              : Colors.white24,
        ),
      ),
      child: Text(
        card,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isRed ? const Color(0xFFE74C3C) : Colors.white,
        ),
      ),
    );
  }
}
