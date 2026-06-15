import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/football_match.dart';
import '../models/player.dart';
import '../models/player_performance.dart';
import '../models/team.dart';
import '../services/firestore_service.dart';

class AppData extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription? _teamSubscription;
  StreamSubscription? _playersSubscription;
  StreamSubscription? _matchesSubscription;

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

  void startFirebaseListeners() {
    _teamSubscription?.cancel();
    _playersSubscription?.cancel();
    _matchesSubscription?.cancel();

    _teamSubscription = _firestoreService.watchTeam().listen((snapshot) {
      final data = snapshot.data();

      if (data != null) {
        _team = _teamFromMap(data);
        notifyListeners();
      }
    });

    _playersSubscription = _firestoreService.watchPlayers().listen((snapshot) {
      _players
        ..clear()
        ..addAll(
          snapshot.docs.map(
            (doc) => _playerFromMap(doc.id, doc.data()),
          ),
        );

      notifyListeners();
    });

    _matchesSubscription = _firestoreService.watchMatches().listen((snapshot) {
      _matches
        ..clear()
        ..addAll(
          snapshot.docs.map(
            (doc) => _matchFromMap(doc.id, doc.data()),
          ),
        );

      notifyListeners();
    });
  }

  void stopFirebaseListeners() {
    _teamSubscription?.cancel();
    _playersSubscription?.cancel();
    _matchesSubscription?.cancel();

    _teamSubscription = null;
    _playersSubscription = null;
    _matchesSubscription = null;

    _team = Team(
      name: 'Meu Time',
      nickname: 'Time',
      city: '',
      category: 'Futebol',
    );

    _players.clear();
    _matches.clear();

    notifyListeners();
  }

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

    _safeFirestoreWrite(
      _firestoreService.saveTeam(_teamToMap(_team)),
    );
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

    _safeFirestoreWrite(
      _firestoreService.playersRef.doc(player.id).set({
        ..._playerToMap(player),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
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

    final player = Player(
      id: id,
      name: name,
      position: position,
      shirtNumber: shirtNumber,
    );

    _players[index] = player;
    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.playersRef.doc(id).set({
        ..._playerToMap(player),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
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

      final updatedMatch = match.copyWith(
        performances: updatedPerformances,
      );

      _matches[i] = updatedMatch;

      _safeFirestoreWrite(
        _firestoreService.matchesRef.doc(updatedMatch.id).set({
          ..._matchToMap(updatedMatch),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      );
    }

    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.deletePlayer(playerId),
    );
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

    _safeFirestoreWrite(
      _firestoreService.matchesRef.doc(match.id).set({
        ..._matchToMap(match),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
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

    final updatedMatch = oldMatch.copyWith(
      opponent: opponent,
      date: date,
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
    );

    _matches[index] = updatedMatch;
    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.matchesRef.doc(id).set({
        ..._matchToMap(updatedMatch),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  void deleteMatch(String matchId) {
    _matches.removeWhere(
      (match) => match.id == matchId,
    );

    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.deleteMatch(matchId),
    );
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

    final updatedMatch = match.copyWith(
      performances: updatedPerformances,
    );

    _matches[matchIndex] = updatedMatch;
    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.matchesRef.doc(matchId).set({
        ..._matchToMap(updatedMatch),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
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

    final updatedMatch = match.copyWith(
      performances: updatedPerformances,
    );

    _matches[matchIndex] = updatedMatch;
    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.matchesRef.doc(matchId).set({
        ..._matchToMap(updatedMatch),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
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

    final updatedMatch = match.copyWith(
      performances: updatedPerformances,
    );

    _matches[matchIndex] = updatedMatch;
    notifyListeners();

    _safeFirestoreWrite(
      _firestoreService.matchesRef.doc(matchId).set({
        ..._matchToMap(updatedMatch),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
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

  Map<String, dynamic> _teamToMap(Team team) {
    return {
      'name': team.name,
      'nickname': team.nickname,
      'city': team.city,
      'category': team.category,
    };
  }

  Team _teamFromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'] ?? 'Meu Time',
      nickname: map['nickname'] ?? 'Time',
      city: map['city'] ?? '',
      category: map['category'] ?? 'Futebol',
    );
  }

  Map<String, dynamic> _playerToMap(Player player) {
    return {
      'name': player.name,
      'position': player.position,
      'shirtNumber': player.shirtNumber,
    };
  }

  Player _playerFromMap(String id, Map<String, dynamic> map) {
    return Player(
      id: id,
      name: map['name'] ?? '',
      position: map['position'] ?? '',
      shirtNumber: map['shirtNumber'] ?? 0,
    );
  }

  Map<String, dynamic> _matchToMap(FootballMatch match) {
    return {
      'opponent': match.opponent,
      'date': match.date,
      'teamGoals': match.teamGoals,
      'opponentGoals': match.opponentGoals,
      'performances': match.performances.map(_performanceToMap).toList(),
    };
  }

  FootballMatch _matchFromMap(String id, Map<String, dynamic> map) {
    return FootballMatch(
      id: id,
      opponent: map['opponent'] ?? '',
      date: _dateFromFirestore(map['date']),
      teamGoals: map['teamGoals'] ?? 0,
      opponentGoals: map['opponentGoals'] ?? 0,
      performances: _performancesFromFirestore(map['performances']),
    );
  }

  Map<String, dynamic> _performanceToMap(PlayerPerformance performance) {
    return {
      'id': performance.id,
      'playerId': performance.playerId,
      'goals': performance.goals,
      'assists': performance.assists,
      'yellowCards': performance.yellowCards,
      'redCards': performance.redCards,
      'minutesPlayed': performance.minutesPlayed,
      'rating': performance.rating,
    };
  }

  List<PlayerPerformance> _performancesFromFirestore(dynamic value) {
    if (value is! List) return [];

    return value.map((item) {
      final map = Map<String, dynamic>.from(item as Map);

      return PlayerPerformance(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        playerId: map['playerId'] ?? '',
        goals: map['goals'] ?? 0,
        assists: map['assists'] ?? 0,
        yellowCards: map['yellowCards'] ?? 0,
        redCards: map['redCards'] ?? 0,
        minutesPlayed: map['minutesPlayed'] ?? 0,
        rating: (map['rating'] ?? 0).toDouble(),
      );
    }).toList();
  }

  DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  void _safeFirestoreWrite(Future<void> future) {
    future.catchError((error) {
      debugPrint('Erro ao salvar no Firestore: $error');
    });
  }

  @override
  void dispose() {
    _teamSubscription?.cancel();
    _playersSubscription?.cancel();
    _matchesSubscription?.cancel();
    super.dispose();
  }
}