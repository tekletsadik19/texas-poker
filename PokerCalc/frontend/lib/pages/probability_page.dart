import 'package:flutter/material.dart';
import '../api_client.dart';
import '../widgets/card_input.dart';

class ProbabilityPage extends StatefulWidget {
  const ProbabilityPage({super.key});

  @override
  State<ProbabilityPage> createState() => _ProbabilityPageState();
}

class _ProbabilityPageState extends State<ProbabilityPage> {
  final List<TextEditingController> _hole = List.generate(
    2,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _comm = List.generate(
    5,
    (_) => TextEditingController(),
  );
  int _numPlayers = 2;
  int _simulations = 10000;
  String _street = 'Pre-Flop';
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  final Map<String, int> _streetComm = {
    'Pre-Flop': 0,
    'Flop': 3,
    'Turn': 4,
    'River': 5,
  };

  @override
  void dispose() {
    for (final c in [..._hole, ..._comm]) c.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final hole = _hole.map((c) => c.text.trim().toUpperCase()).toList();
    if (hole.any((c) => c.length != 2)) {
      setState(() => _error = 'Both hole cards are required (e.g. HA, SA)');
      return;
    }

    final commCount = _streetComm[_street]!;
    final comm = _comm
        .sublist(0, commCount)
        .map((c) => c.text.trim().toUpperCase())
        .toList();
    if (commCount > 0 && comm.any((c) => c.length != 2)) {
      setState(
        () =>
            _error = 'All required community cards must be filled for $_street',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ApiClient.probability(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Hole Cards'),
          const SizedBox(height: 10),
          CardRow(controllers: _hole, labels: ['Hole 1', 'Hole 2']),
          const SizedBox(height: 20),
          _label('Street'),
          const SizedBox(height: 10),
          _streetSelector(),
          if (commCount > 0) ...[
            const SizedBox(height: 20),
            _label('Community Cards'),
            const SizedBox(height: 10),
            if (commCount >= 3)
              CardRow(
                controllers: _comm.sublist(0, 3),
                labels: ['Flop 1', 'Flop 2', 'Flop 3'],
              ),
            if (commCount >= 4) ...[
              const SizedBox(height: 8),
              CardRow(controllers: _comm.sublist(3, 4), labels: ['Turn']),
            ],
            if (commCount == 5) ...[
              const SizedBox(height: 8),
              CardRow(controllers: _comm.sublist(4), labels: ['River']),
            ],
          ],
          const SizedBox(height: 20),
          _label('Number of Players'),
          const SizedBox(height: 10),
          _playerSlider(),
          const SizedBox(height: 20),
          _label('Simulations'),
          const SizedBox(height: 10),
          _simSelector(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
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
                  : Text(
                      'Run $_simulations Simulations',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1515),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE74C3C), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE74C3C),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFE74C3C)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            _probResult(_result!),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF8FA4BB),
      letterSpacing: 1.2,
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
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF1E2A35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2C3E50),
                ),
              ),
              child: Center(
                child: Text(
                  s,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF8FA4BB),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _playerSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C3E50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Color(0xFF8FA4BB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Slider(
              value: _numPlayers.toDouble(),
              min: 2,
              max: 9,
              divisions: 7,
              activeColor: const Color(0xFFE74C3C),
              inactiveColor: const Color(0xFF2C3E50),
              onChanged: (v) => setState(() => _numPlayers = v.round()),
            ),
          ),
          Text(
            '$_numPlayers',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _simSelector() {
    final options = [1000, 5000, 10000, 50000];
    return Row(
      children: options.map((n) {
        final selected = n == _simulations;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _simulations = n),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF1E2A35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2C3E50),
                ),
              ),
              child: Center(
                child: Text(
                  n >= 1000 ? '${n ~/ 1000}k' : '$n',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF8FA4BB),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _probResult(Map<String, dynamic> result) {
    final win = (result['win_probability'] as num).toDouble();
    final tie = (result['tie_probability'] as num).toDouble();
    final loss = (result['loss_probability'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE74C3C).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Win Probability',
            style: TextStyle(
              color: Color(0xFF8FA4BB),
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _probBar('Win', win, const Color(0xFF27AE60)),
          const SizedBox(height: 10),
          _probBar('Tie', tie, const Color(0xFFF1C40F)),
          const SizedBox(height: 10),
          _probBar('Loss', loss, const Color(0xFFE74C3C)),
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
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: prob.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
