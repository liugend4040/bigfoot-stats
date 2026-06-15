import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchAnnouncementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não está logado.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get announcementsRef {
    return _db.collection('match_announcements');
  }

  CollectionReference<Map<String, dynamic>> matchesRefForUser(String userId) {
    return _db.collection('users').doc(userId).collection('matches');
  }

  Future<void> createAnnouncement({
    required String teamName,
    required String teamNickname,
    required String city,
    required String category,
    required String opponentPreference,
    required DateTime date,
    required String location,
    required String description,
  }) async {
    await announcementsRef.add({
      'ownerUid': uid,
      'teamName': teamName,
      'teamNickname': teamNickname,
      'city': city,
      'category': category,
      'opponentPreference': opponentPreference,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'status': 'open',
      'acceptedByUid': null,
      'acceptedByTeamName': null,
      'acceptedAt': null,
      'confirmedAt': null,
      'declinedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchOpenAnnouncements() {
    return announcementsRef
        .where('status', isEqualTo: 'open')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyAnnouncements() {
    return announcementsRef
        .where('ownerUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAcceptedByMe() {
    return announcementsRef
        .where('acceptedByUid', isEqualTo: uid)
        .snapshots();
  }

  Future<void> acceptAnnouncement({
    required String announcementId,
    required String acceptedByTeamName,
  }) async {
    final docRef = announcementsRef.doc(announcementId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Anúncio não encontrado.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Anúncio inválido.');
      }

      if (data['ownerUid'] == uid) {
        throw Exception('Você não pode solicitar sua própria partida.');
      }

      if (data['status'] != 'open') {
        throw Exception('Essa partida não está mais disponível.');
      }

      transaction.update(docRef, {
        'status': 'pending_confirmation',
        'acceptedByUid': uid,
        'acceptedByTeamName': acceptedByTeamName,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> confirmAnnouncement(String announcementId) async {
    final announcementRef = announcementsRef.doc(announcementId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(announcementRef);

      if (!snapshot.exists) {
        throw Exception('Anúncio não encontrado.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Anúncio inválido.');
      }

      final ownerUid = data['ownerUid'];
      final acceptedByUid = data['acceptedByUid'];

      if (ownerUid != uid) {
        throw Exception('Você só pode confirmar seus próprios anúncios.');
      }

      if (data['status'] != 'pending_confirmation') {
        throw Exception('Essa solicitação não está aguardando confirmação.');
      }

      if (acceptedByUid == null) {
        throw Exception('Nenhum time solicitou essa partida.');
      }

      final announcementIdAsMatchId = announcementId;
      final matchDate = data['date'] ?? Timestamp.now();

      final ownerMatchRef = matchesRefForUser(ownerUid).doc(
        announcementIdAsMatchId,
      );

      final acceptedTeamMatchRef = matchesRefForUser(acceptedByUid).doc(
        announcementIdAsMatchId,
      );

      transaction.update(announcementRef, {
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(ownerMatchRef, {
        'opponent': data['acceptedByTeamName'] ?? 'Adversário',
        'date': matchDate,
        'teamGoals': 0,
        'opponentGoals': 0,
        'performances': [],
        'source': 'match_announcement',
        'announcementId': announcementId,
        'matchStatus': 'confirmed',
        'location': data['location'] ?? '',
        'description': data['description'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(acceptedTeamMatchRef, {
        'opponent': data['teamName'] ?? 'Adversário',
        'date': matchDate,
        'teamGoals': 0,
        'opponentGoals': 0,
        'performances': [],
        'source': 'match_announcement',
        'announcementId': announcementId,
        'matchStatus': 'confirmed',
        'location': data['location'] ?? '',
        'description': data['description'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> declineAnnouncement(String announcementId) async {
    final docRef = announcementsRef.doc(announcementId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Anúncio não encontrado.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Anúncio inválido.');
      }

      if (data['ownerUid'] != uid) {
        throw Exception('Você só pode recusar solicitações dos seus anúncios.');
      }

      if (data['status'] != 'pending_confirmation') {
        throw Exception('Essa solicitação não está aguardando confirmação.');
      }

      transaction.update(docRef, {
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelAnnouncement(String announcementId) async {
    final docRef = announcementsRef.doc(announcementId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('Anúncio não encontrado.');
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception('Anúncio inválido.');
    }

    if (data['ownerUid'] != uid) {
      throw Exception('Você só pode cancelar seus próprios anúncios.');
    }

    await docRef.update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reopenAnnouncement(String announcementId) async {
    final docRef = announcementsRef.doc(announcementId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('Anúncio não encontrado.');
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception('Anúncio inválido.');
    }

    if (data['ownerUid'] != uid) {
      throw Exception('Você só pode reabrir seus próprios anúncios.');
    }

    await docRef.update({
      'status': 'open',
      'acceptedByUid': null,
      'acceptedByTeamName': null,
      'acceptedAt': null,
      'confirmedAt': null,
      'declinedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}