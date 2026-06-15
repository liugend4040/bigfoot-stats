import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não está logado.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get playersRef {
    return _db.collection('users').doc(uid).collection('players');
  }

  CollectionReference<Map<String, dynamic>> get matchesRef {
    return _db.collection('users').doc(uid).collection('matches');
  }

  DocumentReference<Map<String, dynamic>> get teamRef {
    return _db.collection('users').doc(uid).collection('settings').doc('team');
  }

  Future<String> addPlayer(Map<String, dynamic> data) async {
    final doc = await playersRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updatePlayer(String id, Map<String, dynamic> data) async {
    await playersRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePlayer(String id) async {
    await playersRef.doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPlayers() {
    return playersRef.orderBy('createdAt').snapshots();
  }

  Future<String> addMatch(Map<String, dynamic> data) async {
    final doc = await matchesRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateMatch(String id, Map<String, dynamic> data) async {
    await matchesRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMatch(String id) async {
    await matchesRef.doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMatches() {
    return matchesRef.orderBy('createdAt').snapshots();
  }

  Future<void> saveTeam(Map<String, dynamic> data) async {
    await teamRef.set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchTeam() {
    return teamRef.snapshots();
  }
}