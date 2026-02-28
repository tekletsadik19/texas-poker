import 'package:flutter/material.dart';
import '../../main.dart';
import '../widgets/visual_card_slot.dart';
import '../widgets/playing_card.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final List<String?> _p1Hole = [null, null];
  final List<String?> _p2Hole = [null, null];
  final List<String?> _comm = [null, null, null, null, null];

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _compare() async {
    final p1h = _p1Hole.whereType<String>().toList();
    final p2h = _p2Hole.whereType<String>().toList();
    final comm = _comm.whereType<String>().toList();

    if (p1h.length < 2 || p2h.length < 2) {
      setState(() => _error = 'Select 2 hole cards for both players');
      return;
    }
    if (comm.length < 3) {
      setState(() => _error = 'Select at least 3 community cards (Flop)');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await pokerRepository.compareHands(p1h, comm, p2h, comm);
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _playerSection(
                  'PLAYER A',
                  _p1Hole,
                  const Color(0xFF3498DB),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _playerSection(
                  'PLAYER B',
                  _p2Hole,
                  const Color(0xFFE67E22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text(
            'SHARED BOARD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6E7681),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              5,
              (i) => VisualCardSlot(
                cardId: _comm[i],
                label: _getCommLabel(i),
                onCardChanged: (v) => setState(() => _comm[i] = v),
                width: 55,
              ),
            ),
          ),
          const SizedBox(height: 48),
          _actionButton(),
          if (_error != null) ...[
            const SizedBox(height: 24),
            _errorCard(_error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 48),
            _resultPanel(_result!),
          ],
        ],
      ),
    );
  }

  String _getCommLabel(int i) {
    if (i < 3) return 'FLOP ${i + 1}';
    if (i == 3) return 'TURN';
    return 'RIVER';
  }

  Widget _playerSection(String name, List<String?> hole, Color accent) =>
      Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VisualCardSlot(
                cardId: hole[0],
                label: 'H1',
                onCardChanged: (v) => setState(() => hole[0] = v),
                width: 65,
              ),
              const SizedBox(width: 12),
              VisualCardSlot(
                cardId: hole[1],
                label: 'H2',
                onCardChanged: (v) => setState(() => hole[1] = v),
                width: 65,
              ),
            ],
          ),
        ],
      );

  Widget _actionButton() => Container(
    width: 240,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8E44AD).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: _loading ? null : _compare,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8E44AD),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _loading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Text(
              'RUN SHOWDOWN',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
    ),
  );

  Widget _errorCard(String error) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF2A1515),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE74C3C)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            error,
            style: const TextStyle(
              color: Color(0xFFE74C3C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _resultPanel(Map<String, dynamic> result) {
    final winner = result['winner'] as int;
    final p1 = result['player1_eval'] as Map<String, dynamic>;
    final p2 = result['player2_eval'] as Map<String, dynamic>;
    final Color winColor = winner == 1
        ? const Color(0xFF3498DB)
        : (winner == 2 ? const Color(0xFFE67E22) : const Color(0xFFF1C40F));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: winColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: winColor.withOpacity(0.4), width: 2),
          ),
          child: Center(
            child: Text(
              winner == 0
                  ? 'IT\'S A TIE'
                  : (winner == 1 ? 'PLAYER A WINS' : 'PLAYER B WINS'),
              style: TextStyle(
                color: winColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _playerResultCard(
                'PLAYER A',
                p1,
                const Color(0xFF3498DB),
                winner == 1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _playerResultCard(
                'PLAYER B',
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

  Widget _playerResultCard(
    String name,
    Map<String, dynamic> eval,
    Color accent,
    bool isWinner,
  ) {
    final cards = List<String>.from(eval['best_cards'] ?? []);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWinner ? accent : const Color(0xFF30363D),
          width: isWinner ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eval['rank_name'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: cards
                .map((c) => PlayingCard(cardId: c, width: 45))
                .toList(),
          ),
        ],
      ),
    );
  }
}
