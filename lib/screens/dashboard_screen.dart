import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    final players = appData.players;
    final matches = appData.matches;

    int totalGoals = 0;
    int totalAssists = 0;
    int totalPerformances = 0;

    for (final match in matches) {
      for (final performance in match.performances) {
        totalGoals += performance.goals;
        totalAssists += performance.assists;
        totalPerformances++;
      }
    }

    final topScorers = [...players];
    topScorers.sort(
      (a, b) => appData
          .totalGoalsByPlayer(b.id)
          .compareTo(appData.totalGoalsByPlayer(a.id)),
    );

    final topAssists = [...players];
    topAssists.sort(
      (a, b) => appData
          .totalAssistsByPlayer(b.id)
          .compareTo(appData.totalAssistsByPlayer(a.id)),
    );

    final topRatings = [...players];
    topRatings.sort(
      (a, b) => appData
          .averageRatingByPlayer(b.id)
          .compareTo(appData.averageRatingByPlayer(a.id)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Resumo geral',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _InfoCard(
              title: 'Jogadores cadastrados',
              value: players.length.toString(),
              icon: Icons.group,
            ),
            _InfoCard(
              title: 'Partidas criadas',
              value: matches.length.toString(),
              icon: Icons.sports_soccer,
            ),
            _InfoCard(
              title: 'Desempenhos registrados',
              value: totalPerformances.toString(),
              icon: Icons.assignment,
            ),
            _InfoCard(
              title: 'Gols registrados',
              value: totalGoals.toString(),
              icon: Icons.sports_score,
            ),
            _InfoCard(
              title: 'Assistências registradas',
              value: totalAssists.toString(),
              icon: Icons.handshake,
            ),

            const SizedBox(height: 24),

            _RankingSection(
              title: 'Artilheiros',
              players: topScorers,
              getValue: (player) {
                return '${appData.totalGoalsByPlayer(player.id)} gols';
              },
            ),

            const SizedBox(height: 24),

            _RankingSection(
              title: 'Líderes em assistências',
              players: topAssists,
              getValue: (player) {
                return '${appData.totalAssistsByPlayer(player.id)} assist.';
              },
            ),

            const SizedBox(height: 24),

            _RankingSection(
              title: 'Melhores médias',
              players: topRatings,
              getValue: (player) {
                return appData
                    .averageRatingByPlayer(player.id)
                    .toStringAsFixed(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RankingSection extends StatelessWidget {
  final String title;
  final List players;
  final String Function(dynamic player) getValue;

  const _RankingSection({
    required this.title,
    required this.players,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    final visiblePlayers = players.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        if (visiblePlayers.isEmpty)
          const Card(
            child: ListTile(
              title: Text('Nenhum jogador cadastrado.'),
            ),
          )
        else
          ...visiblePlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(player.name),
                subtitle: Text(player.position),
                trailing: Text(
                  getValue(player),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}