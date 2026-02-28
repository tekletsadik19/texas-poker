import '../entities/hand_eval_entity.dart';
import '../entities/probability_entity.dart';

abstract class PokerRepository {
  Future<HandEvalEntity> getBestHand(List<String> hole, List<String> community);
  Future<Map<String, dynamic>> compareHands(
    List<String> p1Hole,
    List<String> p1Comm,
    List<String> p2Hole,
    List<String> p2Comm,
  );
  Future<ProbabilityEntity> getProbability(
    List<String> hole,
    List<String> community,
    int players,
    int simulations,
  );
}
