import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class EditMatchScreen extends StatefulWidget {
  final String matchId;

  const EditMatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _opponentController;
  late TextEditingController _teamGoalsController;
  late TextEditingController _opponentGoalsController;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final appData = Provider.of<AppData>(
      context,
      listen: false,
    );

    final match = appData.getMatchById(widget.matchId);

    _opponentController = TextEditingController(
      text: match?.opponent ?? '',
    );

    _teamGoalsController = TextEditingController(
      text: match?.teamGoals.toString() ?? '0',
    );

    _opponentGoalsController = TextEditingController(
      text: match?.opponentGoals.toString() ?? '0',
    );

    _selectedDate = match?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _teamGoalsController.dispose();
    _opponentGoalsController.dispose();
    super.dispose();
  }

  void _saveMatch() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<AppData>(
      context,
      listen: false,
    ).updateMatch(
      id: widget.matchId,
      opponent: _opponentController.text.trim(),
      date: _selectedDate,
      teamGoals: int.parse(_teamGoalsController.text),
      opponentGoals: int.parse(_opponentGoalsController.text),
    );

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    setState(() {
      _selectedDate = date;
    });
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

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final team = appData.team;
    final match = appData.getMatchById(widget.matchId);

    if (match == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Partida'),
        ),
        body: const Center(
          child: Text('Partida não encontrada.'),
        ),
      );
    }

    final formattedDate =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Partida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Time: ${team.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _opponentController,
                decoration: const InputDecoration(
                  labelText: 'Adversário',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o adversário';
                  }

                  return null;
                },
              ),

              TextFormField(
                controller: _teamGoalsController,
                decoration: InputDecoration(
                  labelText: 'Gols do ${team.nickname}',
                ),
                keyboardType: TextInputType.number,
                validator: _validateInt,
              ),

              TextFormField(
                controller: _opponentGoalsController,
                decoration: const InputDecoration(
                  labelText: 'Gols do adversário',
                ),
                keyboardType: TextInputType.number,
                validator: _validateInt,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text('Data: $formattedDate'),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Alterar'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveMatch,
                child: const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}