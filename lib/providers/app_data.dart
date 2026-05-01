import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/football_match.dart';
import '../models/player_performance.dart';
import '../models/team.dart';

class AppData extends ChangeNotifier {
  Team _team = Team(
    name: 'Meu Time',
    nickname: 'Time',
    city: '',
    category: 'Futebol',
  );

  final List<Player> _players = [];
  final List<FootballMatch> _matches = [];

  Team get team => _team;

  List<Player> get players => [..._players];
  List<FootballMatch> get matches => [..._matches];

  void updateTeam({
    required String name,
    required String nickname,
    required String city,
    required String category,
  }) {
    _team = _team.copyWith(
      name: name,
      nickname: nickname,
      city: city,
      category: category,
    );

    notifyListeners();
  }

  void addPlayer({
    required String name,
    required String position,
    required int shirtNumber,
  }) {
    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      position: position,
      shirtNumber: shirtNumber,
    );

    _players.add(player);
    notifyListeners();
  }

  void updatePlayer({
    required String id,
    required String name,
    required String position,
    required int shirtNumber,
  }) {
    final index = _players.indexWhere(
      (player) => player.id == id,
    );

    if (index == -1) return;

    _players[index] = Player(
      id: id,
      name: name,
      position: position,
      shirtNumber: shirtNumber,
    );

    notifyListeners();
  }

  void deletePlayer(String playerId) {
    _players.removeWhere(
      (player) => player.id == playerId,
    );

    for (int i = 0; i < _matches.length; i++) {
      final match = _matches[i];

      final updatedPerformances = match.performances
          .where(
            (performance) => performance.playerId != playerId,
          )
          .toList();

      _matches[i] = match.copyWith(
        performances: updatedPerformances,
      );
    }

    notifyListeners();
  }

  void addMatch({
    required String opponent,
    required DateTime date,
    required int teamGoals,
    required int opponentGoals,
  }) {
    final match = FootballMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      opponent: opponent,
      date: date,
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
    );

    _matches.add(match);
    notifyListeners();
  }

  void updateMatch({
    required String id,
    required String opponent,
    required DateTime date,
    required int teamGoals,
    required int opponentGoals,
  }) {
    final index = _matches.indexWhere(
      (match) => match.id == id,
    );

    if (index == -1) return;

    final oldMatch = _matches[index];

    _matches[index] = oldMatch.copyWith(
      opponent: opponent,
      date: date,
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
    );

    notifyListeners();
  }

  void deleteMatch(String matchId) {
    _matches.removeWhere(
      (match) => match.id == matchId,
    );

    notifyListeners();
  }

  void addPerformanceToMatch({
    required String matchId,
    required String playerId,
    required int goals,
    required int assists,
    required int yellowCards,
    required int redCards,
    required int minutesPlayed,
    required double rating,
  }) {
    final matchIndex = _matches.indexWhere(
      (match) => match.id == matchId,
    );

    if (matchIndex == -1) return;

    final match = _matches[matchIndex];

    final newPerformance = PlayerPerformance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerId: playerId,
      goals: goals,
      assists: assists,
      yellowCards: yellowCards,
      redCards: redCards,
      minutesPlayed: minutesPlayed,
      rating: rating,
    );

    final updatedPerformances = [
      ...match.performances.where(
        (performance) => performance.playerId != playerId,
      ),
      newPerformance,
    ];

    _matches[matchIndex] = match.copyWith(
      performances: updatedPerformances,
    );

    notifyListeners();
  }

  void updatePerformanceInMatch({
    required String matchId,
    required String performanceId,
    required String playerId,
    required int goals,
    required int assists,
    required int yellowCards,
    required int redCards,
    required int minutesPlayed,
    required double rating,
  }) {
    final matchIndex = _matches.indexWhere(
      (match) => match.id == matchId,
    );

    if (matchIndex == -1) return;

    final match = _matches[matchIndex];

    final updatedPerformances = match.performances.map((performance) {
      if (performance.id == performanceId) {
        return PlayerPerformance(
          id: performanceId,
          playerId: playerId,
          goals: goals,
          assists: assists,
          yellowCards: yellowCards,
          redCards: redCards,
          minutesPlayed: minutesPlayed,
          rating: rating,
        );
      }

      return performance;
    }).toList();

    _matches[matchIndex] = match.copyWith(
      performances: updatedPerformances,
    );

    notifyListeners();
  }

  void deletePerformanceFromMatch({
    required String matchId,
    required String performanceId,
  }) {
    final matchIndex = _matches.indexWhere(
      (match) => match.id == matchId,
    );

    if (matchIndex == -1) return;

    final match = _matches[matchIndex];

    final updatedPerformances = match.performances
        .where(
          (performance) => performance.id != performanceId,
        )
        .toList();

    _matches[matchIndex] = match.copyWith(
      performances: updatedPerformances,
    );

    notifyListeners();
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere(
        (player) => player.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  FootballMatch? getMatchById(String id) {
    try {
      return _matches.firstWhere(
        (match) => match.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  PlayerPerformance? getPerformanceById({
    required String matchId,
    required String performanceId,
  }) {
    final match = getMatchById(matchId);

    if (match == null) return null;

    try {
      return match.performances.firstWhere(
        (performance) => performance.id == performanceId,
      );
    } catch (_) {
      return null;
    }
  }

  int totalGoalsByPlayer(String playerId) {
    int total = 0;

    for (final match in _matches) {
      for (final performance in match.performances) {
        if (performance.playerId == playerId) {
          total += performance.goals;
        }
      }
    }

    return total;
  }

  int totalAssistsByPlayer(String playerId) {
    int total = 0;

    for (final match in _matches) {
      for (final performance in match.performances) {
        if (performance.playerId == playerId) {
          total += performance.assists;
        }
      }
    }

    return total;
  }

  double averageRatingByPlayer(String playerId) {
    final ratings = <double>[];

    for (final match in _matches) {
      for (final performance in match.performances) {
        if (performance.playerId == playerId) {
          ratings.add(performance.rating);
        }
      }
    }

    if (ratings.isEmpty) return 0;

    final total = ratings.reduce(
      (a, b) => a + b,
    );

    return total / ratings.length;
  }
}