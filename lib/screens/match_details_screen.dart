import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import 'add_performance_screen.dart';
import 'edit_match_screen.dart';
import 'edit_performance_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailsScreen({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final team = appData.team;

    final match = appData.getMatchById(matchId);

    if (match == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Partida'),
        ),
        body: const Center(
          child: Text('Partida não encontrada.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${team.nickname} x ${match.opponent}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditMatchScreen(
                    matchId: match.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: match.performances.isEmpty
            ? const Center(
                child: Text('Nenhum desempenho registrado.'),
              )
            : ListView.builder(
                itemCount: match.performances.length,
                itemBuilder: (context, index) {
                  final performance = match.performances[index];

                  final player = appData.getPlayerById(
                    performance.playerId,
                  );

                  return Card(
                    child: ListTile(
                      title: Text(
                        player?.name ?? 'Jogador não encontrado',
                      ),
                      subtitle: Text(
                        'Gols: ${performance.goals}\n'
                        'Assistências: ${performance.assists}\n'
                        'Amarelos: ${performance.yellowCards}\n'
                        'Vermelhos: ${performance.redCards}\n'
                        'Minutos: ${performance.minutesPlayed}\n'
                        'Nota: ${performance.rating.toStringAsFixed(1)}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditPerformanceScreen(
                              matchId: match.id,
                              performanceId: performance.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddPerformanceScreen(
                matchId: match.id,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}