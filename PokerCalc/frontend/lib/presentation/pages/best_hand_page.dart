import 'package:flutter/material.dart';
import '../../main.dart';
import '../../domain/entities/hand_eval_entity.dart';
import '../widgets/visual_card_slot.dart';
import '../widgets/playing_card.dart';

class BestHandPage extends StatefulWidget {
  const BestHandPage({super.key});

  @override
  State<BestHandPage> createState() => _BestHandPageState();
}

class _BestHandPageState extends State<BestHandPage> {
  final List<String?> _hole = [null, null];
  final List<String?> _comm = [null, null, null, null, null];

  bool _loading = false;
  String? _error;
  HandEvalEntity? _result;

  Future<void> _evaluate() async {
    final hole = _hole.whereType<String>().toList();
    final comm = _comm.whereType<String>().toList();

    if (hole.length < 2) {
      setState(() => _error = 'Select 2 hole cards');
      return;
    }
    if (comm.length < 5) {
      setState(
        () => _error = 'Select all 5 community cards (Flop + Turn + River)',
      );
      return;
    }
    final allCards = [...hole, ...comm];
    if (allCards.toSet().length != allCards.length) {
      setState(
        () => _error =
            'Duplicate card detected — each card can only be used once',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await pokerRepository.getBestHand(hole, comm);
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _tableSectionTitle('YOUR HOLE CARDS'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VisualCardSlot(
                cardId: _hole[0],
                label: 'HOLE 1',
                onCardChanged: (v) => setState(() => _hole[0] = v),
              ),
              const SizedBox(width: 16),
              VisualCardSlot(
                cardId: _hole[1],
                label: 'HOLE 2',
                onCardChanged: (v) => setState(() => _hole[1] = v),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _tableSectionTitle('COMMUNITY BOARD'),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              VisualCardSlot(
                cardId: _comm[0],
                label: 'FLOP 1',
                onCardChanged: (v) => setState(() => _comm[0] = v),
              ),
              VisualCardSlot(
                cardId: _comm[1],
                label: 'FLOP 2',
                onCardChanged: (v) => setState(() => _comm[1] = v),
              ),
              VisualCardSlot(
                cardId: _comm[2],
                label: 'FLOP 3',
                onCardChanged: (v) => setState(() => _comm[2] = v),
              ),
              const SizedBox(width: 4),
              VisualCardSlot(
                cardId: _comm[3],
                label: 'TURN',
                onCardChanged: (v) => setState(() => _comm[3] = v),
              ),
              const SizedBox(width: 4),
              VisualCardSlot(
                cardId: _comm[4],
                label: 'RIVER',
                onCardChanged: (v) => setState(() => _comm[4] = v),
              ),
            ],
          ),
          const SizedBox(height: 56),
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

  Widget _tableSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6E7681),
      letterSpacing: 2,
    ),
  );

  Widget _actionButton() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ElevatedButton(
      onPressed: _loading ? null : _evaluate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        disabledBackgroundColor: const Color(0xFFC4C8CC),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: const StadiumBorder(),
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
              'ANALYZE HAND',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
    ),
  );

  Widget _errorCard(String error) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFDEDED),
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

  Widget _resultPanel(HandEvalEntity result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BEST HAND COMBINATION',
            style: TextStyle(
              color: Color(0xFF484F58),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.rankName.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF1C40F),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: result.bestCards
                .map((c) => PlayingCard(cardId: c, width: 64))
                .toList(),
          ),
        ],
      ),
    );
  }
}
