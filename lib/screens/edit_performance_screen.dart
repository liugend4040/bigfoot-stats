import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class EditPerformanceScreen extends StatefulWidget {
  final String matchId;
  final String performanceId;

  const EditPerformanceScreen({
    super.key,
    required this.matchId,
    required this.performanceId,
  });

  @override
  State<EditPerformanceScreen> createState() =>
      _EditPerformanceScreenState();
}

class _EditPerformanceScreenState
    extends State<EditPerformanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _goalsController;
  late TextEditingController _assistsController;
  late TextEditingController _yellowCardsController;
  late TextEditingController _redCardsController;
  late TextEditingController _minutesPlayedController;
  late TextEditingController _ratingController;

  @override
  void initState() {
    super.initState();

    final appData = Provider.of<AppData>(
      context,
      listen: false,
    );

    final performance = appData.getPerformanceById(
      matchId: widget.matchId,
      performanceId: widget.performanceId,
    );

    _goalsController = TextEditingController(
      text: performance?.goals.toString() ?? '0',
    );

    _assistsController = TextEditingController(
      text: performance?.assists.toString() ?? '0',
    );

    _yellowCardsController = TextEditingController(
      text: performance?.yellowCards.toString() ?? '0',
    );

    _redCardsController = TextEditingController(
      text: performance?.redCards.toString() ?? '0',
    );

    _minutesPlayedController = TextEditingController(
      text: performance?.minutesPlayed.toString() ?? '90',
    );

    _ratingController = TextEditingController(
      text: performance?.rating.toString() ?? '7',
    );
  }

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

  String? _validateInt(String? value) {
    final number = int.tryParse(value ?? '');

    if (number == null) {
      return 'Número inválido';
    }

    if (number < 0) {
      return 'Não pode ser negativo';
    }

    return null;
  }

  String? _validateRating(String? value) {
    final number = double.tryParse(value ?? '');

    if (number == null) {
      return 'Nota inválida';
    }

    if (number < 0 || number > 10) {
      return 'A nota deve ser entre 0 e 10';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final appData = Provider.of<AppData>(
      context,
      listen: false,
    );

    final performance = appData.getPerformanceById(
      matchId: widget.matchId,
      performanceId: widget.performanceId,
    );

    if (performance == null) return;

    appData.updatePerformanceInMatch(
      matchId: widget.matchId,
      performanceId: widget.performanceId,
      playerId: performance.playerId,
      goals: int.parse(_goalsController.text),
      assists: int.parse(_assistsController.text),
      yellowCards: int.parse(_yellowCardsController.text),
      redCards: int.parse(_redCardsController.text),
      minutesPlayed: int.parse(_minutesPlayedController.text),
      rating: double.parse(_ratingController.text),
    );

    Navigator.of(context).pop();
  }

  void _delete() {
    Provider.of<AppData>(
      context,
      listen: false,
    ).deletePerformanceFromMatch(
      matchId: widget.matchId,
      performanceId: widget.performanceId,
    );

    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Excluir desempenho'),
          content: const Text(
            'Deseja excluir este desempenho?',
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
      _delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    final performance = appData.getPerformanceById(
      matchId: widget.matchId,
      performanceId: widget.performanceId,
    );

    if (performance == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar desempenho'),
        ),
        body: const Center(
          child: Text('Desempenho não encontrado'),
        ),
      );
    }

    final player = appData.getPlayerById(
      performance.playerId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(player?.name ?? 'Desempenho'),
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                  labelText: 'Nota',
                ),
                keyboardType: TextInputType.number,
                validator: _validateRating,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}