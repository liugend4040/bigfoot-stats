import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _shirtNumberController = TextEditingController();

  String? _selectedPosition;

  final List<String> _positions = const [
    'Goleiro',
    'Zagueiro',
    'Lateral',
    'Volante',
    'Meia',
    'Ponta',
    'Atacante',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _shirtNumberController.dispose();
    super.dispose();
  }

  void _savePlayer() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<AppData>(context, listen: false).addPlayer(
      name: _nameController.text.trim(),
      position: _selectedPosition!,
      shirtNumber: int.parse(_shirtNumberController.text),
    );

    Navigator.of(context).pop();
  }

  String? _validateShirtNumber(String? value) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Jogador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }

                  return null;
                },
              ),

              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Posição',
                ),
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (position) {
                  setState(() {
                    _selectedPosition = position;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione uma posição';
                  }

                  return null;
                },
              ),

              TextFormField(
                controller: _shirtNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número da camisa',
                ),
                keyboardType: TextInputType.number,
                validator: _validateShirtNumber,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _savePlayer,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}