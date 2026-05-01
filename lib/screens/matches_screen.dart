import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import 'add_match_screen.dart';
import 'match_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    String matchId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir partida'),
          content: const Text(
            'Tem certeza que deseja excluir esta partida?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      Provider.of<AppData>(
        context,
        listen: false,
      ).deleteMatch(matchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final team = appData.team;
    final matches = appData.matches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidas'),
      ),
      body: matches.isEmpty
          ? const Center(
              child: Text('Nenhuma partida criada.'),
            )
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];

                return Card(
                  child: ListTile(
                    title: Text('${team.nickname} x ${match.opponent}'),
                    subtitle: Text(
                      '${match.teamGoals} x ${match.opponentGoals}\n'
                      'Desempenhos registrados: ${match.performances.length}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmDelete(context, match.id);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MatchDetailsScreen(
                            matchId: match.id,
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
              builder: (_) => const AddMatchScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}