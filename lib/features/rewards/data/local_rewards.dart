import '../../../core/database.dart';
import '../domain/challenge.dart';
import '../domain/rewards_repository.dart';

class LocalRewards implements RewardsRepository {
  LocalRewards(this.db);
  final DonutDatabase db;

  @override
  Future<List<Challenge>> challenges() async => (await db.records('challenges'))
      .map<Challenge>(
        (r) => (
          title: r['title'],
          current: r['current'],
          goal: r['goal'],
          points: r['points'],
          image: r['image'],
          coffee: r['coffee'],
          gift: r['gift'],
        ),
      )
      .toList(growable: false);
}
