import 'package:flutter/material.dart';
import '../../main.dart';
import '../../domain/entities/probability_entity.dart';
import '../widgets/visual_card_slot.dart';

class ProbabilityPage extends StatefulWidget {
  const ProbabilityPage({super.key});

  @override
  State<ProbabilityPage> createState() => _ProbabilityPageState();
}

class _ProbabilityPageState extends State<ProbabilityPage> {
  final List<String?> _hole = [null, null];
  final List<String?> _comm = [null, null, null, null, null];
  int _numPlayers = 2;
  int _simulations = 10000;
  String _street = 'River';
  bool _loading = false;
  String? _error;
  ProbabilityEntity? _result;

  final Map<String, int> _streetComm = {
    'Pre-Flop': 0,
    'Flop': 3,
    'Turn': 4,
    'River': 5,
  };

  Future<void> _calculate() async {
    final hole = _hole.whereType<String>().toList();
    if (hole.length < 2) {
      setState(() => _error = 'Select 2 hole cards');
      return;
    }

    final commCount = _streetComm[_street]!;
    final comm = _comm.sublist(0, commCount).whereType<String>().toList();
    if (comm.length < commCount) {
      setState(() => _error = 'Select all cards for the $_street board');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await pokerRepository.getProbability(
        hole,
        comm,
        _numPlayers,
        _simulations,
      );
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
    final commCount = _streetComm[_street]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _sectionTitle('YOUR HOLE CARDS'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VisualCardSlot(
                cardId: _hole[0],
                label: 'H1',
                onCardChanged: (v) => setState(() => _hole[0] = v),
                width: 70,
              ),
              const SizedBox(width: 16),
              VisualCardSlot(
                cardId: _hole[1],
                label: 'H2',
                onCardChanged: (v) => setState(() => _hole[1] = v),
                width: 70,
              ),
            ],
          ),
          const SizedBox(height: 40),
          _sectionTitle('STREET & OPPONENTS'),
          const SizedBox(height: 16),
          _streetSelector(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _playerSlider()),
              const SizedBox(width: 12),
              Expanded(child: _simSelector()),
            ],
          ),
          if (commCount > 0) ...[
            const SizedBox(height: 48),
            _sectionTitle('BOARD FOR $_street'),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                commCount,
                (i) => VisualCardSlot(
                  cardId: _comm[i],
                  label: _getCommLabel(i),
                  onCardChanged: (v) => setState(() => _comm[i] = v),
                  width: 55,
                ),
              ),
            ),
          ],
          const SizedBox(height: 56),
          _actionButton(),
          if (_error != null) ...[
            const SizedBox(height: 24),
            _errorCard(_error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 40),
            _probResult(_result!),
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6E7681),
      letterSpacing: 1.5,
    ),
  );

  Widget _streetSelector() {
    return Row(
      children: _streetComm.keys.map((s) {
        final selected = s == _street;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _street = s),
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE74C3C) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFE1E4E8),
                ),
              ),
              child: Center(
                child: Text(
                  s,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF484F58),
                    fontWeight: selected ? FontWeight.w900 : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _playerSlider() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE1E4E8)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.people_alt_outlined,
          size: 18,
          color: Color(0xFF484F58),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFE74C3C),
              inactiveTrackColor: const Color(0xFFE1E4E8),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFFE74C3C).withOpacity(0.1),
            ),
            child: Slider(
              value: _numPlayers.toDouble(),
              min: 2,
              max: 9,
              divisions: 7,
              onChanged: (v) => setState(() => _numPlayers = v.toInt()),
            ),
          ),
        ),
        Text(
          '$_numPlayers',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _simSelector() {
    final options = [1000, 5000, 10000, 50000];
    return Row(
      children: options.map((n) {
        final selected = n == _simulations;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _simulations = n),
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE74C3C) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFE1E4E8),
                ),
              ),
              child: Center(
                child: Text(
                  '${n ~/ 1000}k',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF484F58),
                    fontWeight: selected ? FontWeight.w900 : FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _actionButton() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ElevatedButton(
      onPressed: _loading ? null : _calculate,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE74C3C),
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
              'CALCULATE ODDS',
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

  Widget _probResult(ProbabilityEntity result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _probBar('WIN PROBABILITY', result.win, const Color(0xFF27AE60)),
          const SizedBox(height: 16),
          _probBar('TIE PROBABILITY', result.tie, const Color(0xFFF1C40F)),
          const SizedBox(height: 16),
          _probBar('LOSS PROBABILITY', result.loss, const Color(0xFFE74C3C)),
        ],
      ),
    );
  }

  Widget _probBar(String label, double prob, Color color) {
    final pct = (prob * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: prob,
            minHeight: 12,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
