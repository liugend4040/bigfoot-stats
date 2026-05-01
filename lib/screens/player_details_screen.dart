import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import 'edit_player_screen.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final String playerId;

  const PlayerDetailsScreen({
    super.key,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final team = appData.team;
    final player = appData.getPlayerById(playerId);

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Jogador'),
        ),
        body: const Center(
          child: Text('Jogador não encontrado.'),
        ),
      );
    }

    final goals = appData.totalGoalsByPlayer(player.id);
    final assists = appData.totalAssistsByPlayer(player.id);
    final averageRating = appData.averageRatingByPlayer(player.id);

    final playerMatches = appData.matches.where((match) {
      return match.performances.any(
        (performance) => performance.playerId == player.id,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditPlayerScreen(
                    playerId: player.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                player.shirtNumber.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                player.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                '${player.position} • Camisa ${player.shirtNumber}',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                team.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Estatísticas gerais',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                title: const Text('Partidas jogadas'),
                trailing: Text(playerMatches.length.toString()),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('Gols'),
                trailing: Text(goals.toString()),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('Assistências'),
                trailing: Text(assists.toString()),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('Média de nota'),
                trailing: Text(averageRating.toStringAsFixed(1)),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Histórico de partidas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (playerMatches.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('Nenhuma partida registrada.'),
                ),
              )
            else
              ...playerMatches.map((match) {
                final performance = match.performances.firstWhere(
                  (performance) => performance.playerId == player.id,
                );

                final formattedDate =
                    '${match.date.day}/${match.date.month}/${match.date.year}';

                return Card(
                  child: ListTile(
                    title: Text('${team.nickname} x ${match.opponent}'),
                    subtitle: Text(
                      'Data: $formattedDate\n'
                      'Placar: ${match.teamGoals} x ${match.opponentGoals}\n'
                      'Gols: ${performance.goals} | '
                      'Assistências: ${performance.assists} | '
                      'Nota: ${performance.rating.toStringAsFixed(1)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}