import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_up/data/repositories/firestore/firestore_repository.dart';

// class UserActivityManager {
//   static const String _daysVisitedKey = 'daysVisited';
//   static const String _totalHoursKey = 'totalHours';
//   static const String _accessDatesKey = 'accessDates';

//   // Firestore repository to manage user data
//   final FirestoreRepository _firestoreRepository;

//   UserActivityManager(this._firestoreRepository);

//   Future<void> recordUserActivity() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
//     String today = DateTime.now().toIso8601String().split('T')[0];

//     // Record the activity if it's a new day
//     if (!accessDates.contains(today)) {
//       accessDates.add(today);
//       await prefs.setStringList(_accessDatesKey, accessDates);
//     }

//     // Increment total hours
//     int totalHours = (prefs.getInt(_totalHoursKey) ?? 0) + 1;
//     await prefs.setInt(_totalHoursKey, totalHours);

//     // Update Firestore
//     await _firestoreRepository.updateUserActivity();
//   }

//   Future<Map<String, dynamic>> getUserActivity() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
//     int totalHours = prefs.getInt(_totalHoursKey) ?? 0;

//     return {
//       'daysVisited': accessDates.length,
//       'totalHours': totalHours,
//     };
//   }
// }

// class FirestoreRepository {
//   final FirebaseFirestore _firestore;

//   FirestoreRepository(this._firestore);

//   Future<void> saveUserData(User user) async {
//     _firestore.collection('users').doc(user.uid).set({
//       'uid': user.uid,
//       'email': user.email,
//       'name': user.displayName,
//       'photoUrl': user.photoURL,
//     });
//   }

//   Future<void> updateUserActivity() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userId = user.uid;
//       final today = DateTime.now().toIso8601String().split('T')[0];

//       DocumentReference userActivityRef =
//           _firestore.collection('user_activity').doc(userId);

//       await userActivityRef.set({
//         'userId': userId,
//         'accessDates': FieldValue.arrayUnion([today]),
//         'totalHours': FieldValue.increment(1),
//       }, SetOptions(merge: true));
//     }
//   }

//   Future<Map<String, dynamic>> getUserActivity() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userId = user.uid;
//       final snapshot = await _firestore.collection('user_activity').doc(userId).get();

//       if (snapshot.exists) {
//         final data = snapshot.data();
//         return {
//           'daysVisited': (data?['accessDates'] as List)?.length ?? 0,
//           'totalHours': data?['totalHours'] ?? 0,
//         };
//       }
//     }
//     return {
//       'daysVisited': 0,
//       'totalHours': 0,
//     };
//   }
// }
class UserActivityManager {
  static const String _daysVisitedKey = 'daysVisited';
  static const String _totalHoursKey = 'totalHours';
  static const String _accessDatesKey = 'accessDates';
  final FirestoreRepository _firestoreRepository;

  UserActivityManager(this._firestoreRepository);

  Future<void> recordUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    String today = DateTime.now().toIso8601String().split('T')[0];

    if (!accessDates.contains(today)) {
      accessDates.add(today);
      await prefs.setStringList(_accessDatesKey, accessDates);
    }

    int totalHours = (prefs.getInt(_totalHoursKey) ?? 0) + 1;
    await prefs.setInt(_totalHoursKey, totalHours);

    await _firestoreRepository.updateUserActivity();
  }

  Future<Map<String, dynamic>> getUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    int totalHours = prefs.getInt(_totalHoursKey) ?? 0;
    return {
      'daysVisited': accessDates.length,
      'totalHours': totalHours,
    };
  }
}
