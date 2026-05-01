import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import 'add_player_screen.dart';
import 'player_details_screen.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final players = appData.players;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text('Nenhum jogador cadastrado.'),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];

                final goals = appData.totalGoalsByPlayer(player.id);
                final assists = appData.totalAssistsByPlayer(player.id);
                final averageRating =
                    appData.averageRatingByPlayer(player.id);

                return Card(
                  child: ListTile(
                    title: Text(
                      '${player.name} - Camisa ${player.shirtNumber}',
                    ),
                    subtitle: Text(
                      '${player.position}\n'
                      'Gols: $goals | '
                      'Assistências: $assists | '
                      'Média: ${averageRating.toStringAsFixed(1)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerDetailsScreen(
                            playerId: player.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddPlayerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}