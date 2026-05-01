class PlayerPerformance {
  final String id;
  final String playerId;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final int minutesPlayed;
  final double rating;

  PlayerPerformance({
    required this.id,
    required this.playerId,
    required this.goals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
    required this.minutesPlayed,
    required this.rating,
  });
}