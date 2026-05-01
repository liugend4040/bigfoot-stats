import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class EditPlayerScreen extends StatefulWidget {
  final String playerId;

  const EditPlayerScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _shirtNumberController;

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
  void initState() {
    super.initState();

    final appData = Provider.of<AppData>(context, listen: false);
    final player = appData.getPlayerById(widget.playerId);

    _nameController = TextEditingController(text: player?.name ?? '');
    _shirtNumberController = TextEditingController(
      text: player?.shirtNumber.toString() ?? '',
    );

    _selectedPosition = player?.position;

    if (!_positions.contains(_selectedPosition)) {
      _selectedPosition = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shirtNumberController.dispose();
    super.dispose();
  }

  void _savePlayer() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<AppData>(context, listen: false).updatePlayer(
      id: widget.playerId,
      name: _nameController.text.trim(),
      position: _selectedPosition!,
      shirtNumber: int.parse(_shirtNumberController.text),
    );

    Navigator.of(context).pop();
  }

  void _deletePlayer() {
    Provider.of<AppData>(
      context,
      listen: false,
    ).deletePlayer(widget.playerId);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir jogador'),
          content: const Text(
            'Tem certeza que deseja excluir este jogador? '
            'Os desempenhos dele também serão removidos das partidas.',
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
      _deletePlayer();
    }
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
    final player = Provider.of<AppData>(context).getPlayerById(widget.playerId);

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Jogador'),
        ),
        body: const Center(
          child: Text('Jogador não encontrado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Jogador'),
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
                child: const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}