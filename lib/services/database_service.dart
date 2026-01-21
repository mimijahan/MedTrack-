import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Medication>> get medications {
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid).collection('medications').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Medication.fromFirestore(doc.data(), doc.id)).toList()
    );
  }

  Future<void> addMedication(Medication med) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid!).collection('medications').add(med.toFirestore());
  }

  Future<void> markAsTaken(String docId) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid!).collection('medications').doc(docId).update({
      'lastTaken': Timestamp.now(),
    });
  }

  Future<void> deleteMedication(String docId) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid!).collection('medications').doc(docId).delete();
  }
}