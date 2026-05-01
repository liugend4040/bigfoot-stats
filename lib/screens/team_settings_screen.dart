import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class TeamSettingsScreen extends StatefulWidget {
  const TeamSettingsScreen({super.key});

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _cityController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();

    final team = Provider.of<AppData>(
      context,
      listen: false,
    ).team;

    _nameController = TextEditingController(
      text: team.name,
    );

    _nicknameController = TextEditingController(
      text: team.nickname,
    );

    _cityController = TextEditingController(
      text: team.city,
    );

    _categoryController = TextEditingController(
      text: team.category,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _cityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveTeam() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<AppData>(
      context,
      listen: false,
    ).updateTeam(
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      city: _cityController.text.trim(),
      category: _categoryController.text.trim(),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final team = Provider.of<AppData>(context).team;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 42,
                child: Text(
                  team.nickname.isEmpty
                      ? '?'
                      : team.nickname[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do time',
                  hintText: 'Ex: Bigfoot FC',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do time';
                  }

                  return null;
                },
              ),

              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Apelido/Sigla',
                  hintText: 'Ex: Bigfoot',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o apelido do time';
                  }

                  return null;
                },
              ),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  hintText: 'Ex: Feira de Santana',
                ),
              ),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Ex: Fut7, Society, Campo, Futsal',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a categoria';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveTeam,
                child: const Text('Salvar time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}