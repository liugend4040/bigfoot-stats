import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import '../services/match_announcement_service.dart';

class MatchZoneScreen extends StatefulWidget {
  const MatchZoneScreen({super.key});

  @override
  State<MatchZoneScreen> createState() => _MatchZoneScreenState();
}

class _MatchZoneScreenState extends State<MatchZoneScreen> {
  final MatchAnnouncementService _service = MatchAnnouncementService();

  bool _isLoading = false;

  Future<void> _openCreateAnnouncementDialog() async {
    final appData = context.read<AppData>();
    final team = appData.team;

    final opponentPreferenceController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 19, minute: 0);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (picked != null) {
                setDialogState(() {
                  selectedDate = picked;
                });
              }
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: dialogContext,
                initialTime: selectedTime,
              );

              if (picked != null) {
                setDialogState(() {
                  selectedTime = picked;
                });
              }
            }

            return AlertDialog(
              title: const Text('Anunciar partida'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time: ${team.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: opponentPreferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Preferência de adversário',
                        hintText: 'Ex: Sub-17, amador, futsal...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Local da partida',
                        hintText: 'Ex: Arena Bigfoot',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Ex: Procuramos adversário para amistoso.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Data'),
                      subtitle: Text(_formatDate(selectedDate)),
                      onTap: pickDate,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule),
                      title: const Text('Horário'),
                      subtitle: Text(selectedTime.format(dialogContext)),
                      onTap: pickTime,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Publicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      opponentPreferenceController.dispose();
      locationController.dispose();
      descriptionController.dispose();
      return;
    }

    final opponentPreference = opponentPreferenceController.text.trim();
    final location = locationController.text.trim();
    final description = descriptionController.text.trim();

    opponentPreferenceController.dispose();
    locationController.dispose();
    descriptionController.dispose();

    if (location.isEmpty) {
      _showMessage('Informe o local da partida.');
      return;
    }

    final announcementDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.createAnnouncement(
        teamName: team.name,
        teamNickname: team.nickname,
        city: team.city,
        category: team.category,
        opponentPreference: opponentPreference.isEmpty
            ? 'Sem preferência'
            : opponentPreference,
        date: announcementDate,
        location: location,
        description: description.isEmpty
            ? 'Partida anunciada pelo time ${team.name}.'
            : description,
      );

      _showMessage('Partida anunciada com sucesso!');
    } catch (e) {
      _showMessage('Erro ao anunciar partida: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptAnnouncement({
    required String announcementId,
  }) async {
    final team = context.read<AppData>().team;

    if (team.name.trim().isEmpty) {
      _showMessage('Configure o nome do seu time antes de solicitar.');
      return;
    }

    final shouldAccept = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solicitar partida'),
          content: const Text(
            'Deseja enviar uma solicitação para jogar essa partida?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Solicitar'),
            ),
          ],
        );
      },
    );

    if (shouldAccept != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.acceptAnnouncement(
        announcementId: announcementId,
        acceptedByTeamName: team.name,
      );

      _showMessage('Solicitação enviada! Aguarde a confirmação.');
    } catch (e) {
      _showMessage('Erro ao solicitar partida: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAnnouncement(String announcementId) async {
    final shouldConfirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar partida'),
          content: const Text(
            'Deseja confirmar essa partida? Ela será registrada na área Partidas dos dois times.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (shouldConfirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.confirmAnnouncement(announcementId);
      _showMessage('Partida confirmada e registrada!');
    } catch (e) {
      _showMessage('Erro ao confirmar partida: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _declineAnnouncement(String announcementId) async {
    final shouldDecline = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recusar solicitação'),
          content: const Text(
            'Deseja recusar essa solicitação de partida?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Recusar'),
            ),
          ],
        );
      },
    );

    if (shouldDecline != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.declineAnnouncement(announcementId);
      _showMessage('Solicitação recusada.');
    } catch (e) {
      _showMessage('Erro ao recusar solicitação: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAnnouncement(String announcementId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.cancelAnnouncement(announcementId);
      _showMessage('Anúncio cancelado.');
    } catch (e) {
      _showMessage('Erro ao cancelar anúncio: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reopenAnnouncement(String announcementId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.reopenAnnouncement(announcementId);
      _showMessage('Anúncio reaberto.');
    } catch (e) {
      _showMessage('Erro ao reabrir anúncio: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAnnouncementList({
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required String emptyMessage,
    required String mode,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erro ao carregar: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        docs.sort((a, b) {
          final aDate = _sortDateFromMap(a.data());
          final bDate = _sortDateFromMap(b.data());
          return bDate.compareTo(aDate);
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            return _AnnouncementCard(
              docId: doc.id,
              data: doc.data(),
              mode: mode,
              currentUid: FirebaseAuth.instance.currentUser?.uid,
              onAccept: () {
                _acceptAnnouncement(announcementId: doc.id);
              },
              onConfirm: () {
                _confirmAnnouncement(doc.id);
              },
              onDecline: () {
                _declineAnnouncement(doc.id);
              },
              onCancel: () {
                _cancelAnnouncement(doc.id);
              },
              onReopen: () {
                _reopenAnnouncement(doc.id);
              },
            );
          },
        );
      },
    );
  }

  DateTime _sortDateFromMap(Map<String, dynamic> data) {
    final updatedAt = data['updatedAt'];
    final createdAt = data['createdAt'];
    final date = data['date'];

    if (updatedAt != null) return _dateFromFirestore(updatedAt);
    if (createdAt != null) return _dateFromFirestore(createdAt);
    return _dateFromFirestore(date);
  }

  DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zona de Partidas'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.public),
                text: 'Disponíveis',
              ),
              Tab(
                icon: Icon(Icons.outgoing_mail),
                text: 'Solicitações',
              ),
              Tab(
                icon: Icon(Icons.assignment),
                text: 'Meus anúncios',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _openCreateAnnouncementDialog,
          icon: const Icon(Icons.add),
          label: const Text('Anunciar'),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildAnnouncementList(
                  stream: _service.watchOpenAnnouncements(),
                  mode: 'available',
                  emptyMessage:
                      'Nenhuma partida disponível no momento.\n\nClique em "Anunciar" para criar a primeira.',
                ),
                _buildAnnouncementList(
                  stream: _service.watchAcceptedByMe(),
                  mode: 'requests',
                  emptyMessage:
                      'Você ainda não solicitou nenhuma partida.\n\nEntre na aba Disponíveis e solicite uma partida.',
                ),
                _buildAnnouncementList(
                  stream: _service.watchMyAnnouncements(),
                  mode: 'my_announcements',
                  emptyMessage:
                      'Você ainda não anunciou nenhuma partida.\n\nClique em "Anunciar" para criar um anúncio.',
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String mode;
  final String? currentUid;
  final VoidCallback onAccept;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final VoidCallback onCancel;
  final VoidCallback onReopen;

  const _AnnouncementCard({
    required this.docId,
    required this.data,
    required this.mode,
    required this.currentUid,
    required this.onAccept,
    required this.onConfirm,
    required this.onDecline,
    required this.onCancel,
    required this.onReopen,
  });

  DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Disponível';
      case 'pending_confirmation':
        return 'Aguardando confirmação';
      case 'confirmed':
        return 'Partida marcada';
      case 'declined':
        return 'Solicitação recusada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'pending_confirmation':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActions({
    required String status,
    required bool isMine,
  }) {
    if (mode == 'available') {
      if (isMine) {
        return const Text(
          'Você criou este anúncio. Aguarde outro time solicitar.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      return ElevatedButton.icon(
        onPressed: onAccept,
        icon: const Icon(Icons.sports_soccer),
        label: const Text('Solicitar partida'),
      );
    }

    if (mode == 'requests') {
      if (status == 'pending_confirmation') {
        return const Text(
          'Sua solicitação foi enviada. Aguarde a resposta do outro time.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (status == 'confirmed') {
        return const Text(
          'Partida marcada! Ela já foi registrada na área Partidas.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (status == 'declined') {
        return const Text(
          'O outro time recusou essa solicitação.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (status == 'cancelled') {
        return const Text(
          'Esse anúncio foi cancelado pelo dono.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    if (mode == 'my_announcements') {
      if (status == 'open') {
        return OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar anúncio'),
        );
      }

      if (status == 'pending_confirmation') {
        final acceptedByTeamName =
            data['acceptedByTeamName'] ?? 'Um time interessado';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$acceptedByTeamName quer jogar contra você.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close),
                    label: const Text('Recusar'),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      if (status == 'confirmed') {
        return const Text(
          'Partida marcada! Ela já foi registrada na área Partidas dos dois times.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (status == 'declined') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Você recusou essa solicitação.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReopen,
              icon: const Icon(Icons.refresh),
              label: const Text('Reabrir anúncio'),
            ),
          ],
        );
      }

      if (status == 'cancelled') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esse anúncio foi cancelado.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReopen,
              icon: const Icon(Icons.refresh),
              label: const Text('Reabrir anúncio'),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final ownerUid = data['ownerUid'] as String?;
    final isMine = ownerUid == currentUid;

    final status = data['status'] ?? 'open';
    final teamName = data['teamName'] ?? 'Time sem nome';
    final teamNickname = data['teamNickname'] ?? '';
    final city = data['city'] ?? '';
    final category = data['category'] ?? '';
    final opponentPreference =
        data['opponentPreference'] ?? 'Sem preferência';
    final location = data['location'] ?? '';
    final description = data['description'] ?? '';
    final date = _dateFromFirestore(data['date']);

    final statusColor = _statusColor(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Text(
                    teamNickname.toString().isNotEmpty
                        ? teamNickname.toString()[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (city.toString().isNotEmpty) city,
                          if (category.toString().isNotEmpty) category,
                        ].join(' • '),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoRow(
              icon: Icons.calendar_month,
              label: 'Quando',
              value: _formatDateTime(date),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Local',
              value: location.toString(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.sports_soccer,
              label: 'Adversário',
              value: opponentPreference.toString(),
            ),
            if (description.toString().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                description.toString(),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildActions(
              status: status,
              isMine: isMine,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}