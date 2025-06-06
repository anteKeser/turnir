import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for Firebase Realtime Database reference
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

final dataStreamProvider = StreamProvider<List<dynamic>>((ref) {
  final database = ref.read(firebaseDatabaseProvider);
  return database.ref('your/data/path').onValue.map((event) {
    return List.from(event.snapshot.value as List);
  });
});
