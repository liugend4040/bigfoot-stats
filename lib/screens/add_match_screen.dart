import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class AddMatchScreen extends StatefulWidget {
  const AddMatchScreen({super.key});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final _opponentController = TextEditingController();
  final _teamGoalsController = TextEditingController();
  final _opponentGoalsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

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
    ).addMatch(
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
    final team = Provider.of<AppData>(context).team;

    final formattedDate =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Partida'),
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
                child: const Text('Salvar Partida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}