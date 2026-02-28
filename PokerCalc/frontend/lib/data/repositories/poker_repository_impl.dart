import '../../domain/entities/hand_eval_entity.dart';
import '../../domain/entities/probability_entity.dart';
import '../../domain/repositories/poker_repository.dart';
import '../datasources/poker_remote_data_source.dart';

class PokerRepositoryImpl implements PokerRepository {
  final PokerRemoteDataSource remoteDataSource;

  PokerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HandEvalEntity> getBestHand(
    List<String> hole,
    List<String> community,
  ) async {
    final data = await remoteDataSource.post('/hand/best', {
      'hole': hole,
      'community': community,
    });
    return HandEvalEntity(
      rankName: data['rank_name'],
      bestCards: List<String>.from(data['best_cards']),
      score: data['score'],
    );
  }

  @override
  Future<Map<String, dynamic>> compareHands(
    List<String> p1Hole,
    List<String> p1Comm,
    List<String> p2Hole,
    List<String> p2Comm,
  ) async {
    // Return raw map for comparison screen as it has complex nested data
    return await remoteDataSource.post('/hand/compare', {
      'player1_hole': p1Hole,
      'player1_community': p1Comm,
      'player2_hole': p2Hole,
      'player2_community': p2Comm,
    });
  }

  @override
  Future<ProbabilityEntity> getProbability(
    List<String> hole,
    List<String> community,
    int players,
    int simulations,
  ) async {
    final data = await remoteDataSource.post('/hand/probability', {
      'hole_cards': hole,
      'community_cards': community,
      'num_players': players,
      'simulations': simulations,
    });
    return ProbabilityEntity(
      win: (data['win_probability'] as num).toDouble(),
      tie: (data['tie_probability'] as num).toDouble(),
      loss: (data['loss_probability'] as num).toDouble(),
    );
  }
}
