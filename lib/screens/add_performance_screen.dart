import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../providers/app_data.dart';
class AddPerformanceScreen extends StatefulWidget {
  final String matchId;

  const AddPerformanceScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<AddPerformanceScreen> createState() => _AddPerformanceScreenState();
}

class _AddPerformanceScreenState extends State<AddPerformanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _goalsController = TextEditingController(text: '0');
  final _assistsController = TextEditingController(text: '0');
  final _yellowCardsController = TextEditingController(text: '0');
  final _redCardsController = TextEditingController(text: '0');
  final _minutesPlayedController = TextEditingController(text: '90');
  final _ratingController = TextEditingController(text: '7');

  Player? _selectedPlayer;

  @override
  void dispose() {
    _goalsController.dispose();
    _assistsController.dispose();
    _yellowCardsController.dispose();
    _redCardsController.dispose();
    _minutesPlayedController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _savePerformance() {
    if (_selectedPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um jogador.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    Provider.of<AppData>(context, listen: false).addPerformanceToMatch(
      matchId: widget.matchId,
      playerId: _selectedPlayer!.id,
      goals: int.parse(_goalsController.text),
      assists: int.parse(_assistsController.text),
      yellowCards: int.parse(_yellowCardsController.text),
      redCards: int.parse(_redCardsController.text),
      minutesPlayed: int.parse(_minutesPlayedController.text),
      rating: double.parse(_ratingController.text),
    );

    Navigator.of(context).pop();
  }

  String? _validateInt(String? value) {
    final number = int.tryParse(value ?? '');

    if (number == null) {
      return 'Informe um número válido';
    }

    if (number < 0) {
      return 'Não pode ser negativo';
    }

    return null;
  }

  String? _validateRating(String? value) {
    final number = double.tryParse(value ?? '');

    if (number == null) {
      return 'Informe uma nota válida';
    }

    if (number < 0 || number > 10) {
      return 'A nota deve ser entre 0 e 10';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<AppData>(context).players;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Desempenho'),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text('Cadastre jogadores antes de registrar desempenho.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Player>(
                      value: _selectedPlayer,
                      decoration: const InputDecoration(
                        labelText: 'Jogador',
                      ),
                      items: players.map((player) {
                        return DropdownMenuItem<Player>(
                          value: player,
                          child: Text(player.name),
                        );
                      }).toList(),
                      onChanged: (player) {
                        setState(() {
                          _selectedPlayer = player;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _goalsController,
                      decoration: const InputDecoration(
                        labelText: 'Gols',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateInt,
                    ),
                    TextFormField(
                      controller: _assistsController,
                      decoration: const InputDecoration(
                        labelText: 'Assistências',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateInt,
                    ),
                    TextFormField(
                      controller: _yellowCardsController,
                      decoration: const InputDecoration(
                        labelText: 'Cartões amarelos',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateInt,
                    ),
                    TextFormField(
                      controller: _redCardsController,
                      decoration: const InputDecoration(
                        labelText: 'Cartões vermelhos',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateInt,
                    ),
                    TextFormField(
                      controller: _minutesPlayedController,
                      decoration: const InputDecoration(
                        labelText: 'Minutos jogados',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateInt,
                    ),
                    TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Nota de 0 a 10',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateRating,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _savePerformance,
                      child: const Text('Salvar Desempenho'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}