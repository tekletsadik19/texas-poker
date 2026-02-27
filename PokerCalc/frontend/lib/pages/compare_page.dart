import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/card_input.dart';
import '../widgets/playing_card.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final List<TextEditingController> _p1Hole = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _p1Comm = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _p2Hole = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _p2Comm = List.generate(
    5,
    (_) => TextEditingController(),
  );

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    for (final c in [..._p1Hole, ..._p1Comm, ..._p2Hole, ..._p2Comm])
      c.dispose();
    super.dispose();
  }

  Future<void> _compare() async {
    final p1h = _p1Hole.map((c) => c.text.trim().toUpperCase()).toList();
    final p1c = _p1Comm.map((c) => c.text.trim().toUpperCase()).toList();
    final p2h = _p2Hole.map((c) => c.text.trim().toUpperCase()).toList();
    final p2c = _p2Comm.map((c) => c.text.trim().toUpperCase()).toList();

    if ([...p1h, ...p1c, ...p2h, ...p2c].any((c) => c.length != 2)) {
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
      final result = await ApiClient.compareHands(p1h, p1c, p2h, p2c);
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
          _tableHeader(
            'HEAD-TO-HEAD',
            'Compare two players with a shared board.',
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _playerInput(
                  'PLAYER A',
                  _p1Hole,
                  const Color(0xFF3498DB),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _playerInput(
                  'PLAYER B',
                  _p2Hole,
                  const Color(0xFFE67E22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _tableHeader(
            'THE SHARED BOARD',
            'The community cards used by both players.',
          ),
          const SizedBox(height: 16),

          _sectionLabel('FLOP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CardInput(controller: _p1Comm[0], label: 'CARD 1'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CardInput(controller: _p1Comm[1], label: 'CARD 2'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CardInput(controller: _p1Comm[2], label: 'CARD 3'),
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
                    CardInput(controller: _p1Comm[3], label: 'CARD 4'),
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
                    CardInput(controller: _p1Comm[4], label: 'CARD 5'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _compare,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E44AD),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 4,
                shadowColor: const Color(0xFF8E44AD).withOpacity(0.4),
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
                      'RUN HAND COMPARISON',
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
            _resultPanel(_result!),
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Color(0xFF8E44AD),
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
      fontSize: 11,
      fontWeight: FontWeight.w900,
      color: Color(0xFF484F58),
      letterSpacing: 1.5,
    ),
  );

  Widget _playerInput(
    String label,
    List<TextEditingController> controllers,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CardInput(controller: controllers[0], label: 'HOLE 1'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CardInput(controller: controllers[1], label: 'HOLE 2'),
            ),
          ],
        ),
      ],
    );
  }

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

  Widget _resultPanel(Map<String, dynamic> result) {
    final winner = result['winner'] as int;
    final p1 = result['player1_eval'] as Map<String, dynamic>;
    final p2 = result['player2_eval'] as Map<String, dynamic>;

    String headline;
    Color headlineColor;
    IconData headlineIcon;
    if (winner == 0) {
      headline = 'It\'s a Tie!';
      headlineColor = const Color(0xFFF1C40F);
      headlineIcon = Icons.handshake;
    } else if (winner == 1) {
      headline = 'Player 1 Wins!';
      headlineColor = const Color(0xFF3498DB);
      headlineIcon = Icons.emoji_events;
    } else {
      headline = 'Player 2 Wins!';
      headlineColor = const Color(0xFFE67E22);
      headlineIcon = Icons.emoji_events;
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: headlineColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: headlineColor.withOpacity(0.5), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(headlineIcon, color: headlineColor, size: 28),
              const SizedBox(width: 10),
              Text(
                headline,
                style: TextStyle(
                  color: headlineColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _playerResult(
                'Player 1',
                p1,
                const Color(0xFF3498DB),
                winner == 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _playerResult(
                'Player 2',
                p2,
                const Color(0xFFE67E22),
                winner == 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _playerResult(
    String player,
    Map<String, dynamic> eval,
    Color accent,
    bool isWinner,
  ) {
    final cards = List<String>.from(eval['best_cards'] ?? []);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141C22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? accent : const Color(0xFF2C3E50),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            player,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            eval['rank_name'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cards.map((c) {
              return PlayingCard(cardId: c, width: 45);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
