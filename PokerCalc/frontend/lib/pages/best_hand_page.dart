import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/card_input.dart';
import '../widgets/playing_card.dart';

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tableHeader('YOUR HAND', 'The two cards dealt specifically to you.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CardInput(controller: _hole[0], label: 'HOLE 1'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardInput(controller: _hole[1], label: 'HOLE 2'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _tableHeader('THE BOARD', 'Community cards shared by all players.'),
          const SizedBox(height: 16),
          _sectionLabel('FLOP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CardInput(controller: _comm[0], label: 'CARD 1'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CardInput(controller: _comm[1], label: 'CARD 2'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CardInput(controller: _comm[2], label: 'CARD 3'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('TURN'),
                    const SizedBox(height: 8),
                    CardInput(controller: _comm[3], label: 'CARD 4'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('RIVER'),
                    const SizedBox(height: 8),
                    CardInput(controller: _comm[4], label: 'CARD 5'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _evaluate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 4,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.4),
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
                      'ANALYZE BEST HAND',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            _errorCard(_error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 32),
            _resultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _tableHeader(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF8FA4BB)),
      ),
    ],
  );

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
    return PlayingCard(cardId: card, width: 50);
  }
}
