import 'player_performance.dart';

class FootballMatch {
  final String id;
  final String opponent;
  final DateTime date;
  final int teamGoals;
  final int opponentGoals;
  final List<PlayerPerformance> performances;

  FootballMatch({
    required this.id,
    required this.opponent,
    required this.date,
    required this.teamGoals,
    required this.opponentGoals,
    this.performances = const [],
  });

  FootballMatch copyWith({
    String? id,
    String? opponent,
    DateTime? date,
    int? teamGoals,
    int? opponentGoals,
    List<PlayerPerformance>? performances,
  }) {
    return FootballMatch(
      id: id ?? this.id,
      opponent: opponent ?? this.opponent,
      date: date ?? this.date,
      teamGoals: teamGoals ?? this.teamGoals,
      opponentGoals: opponentGoals ?? this.opponentGoals,
      performances: performances ?? this.performances,
    );
  }
}