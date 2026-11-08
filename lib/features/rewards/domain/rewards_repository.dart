import 'challenge.dart';

abstract interface class RewardsRepository {
  Future<List<Challenge>> challenges();
}
