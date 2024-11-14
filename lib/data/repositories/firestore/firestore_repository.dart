import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speak_up/domain/entities/flash_card/flash_card.dart';
import 'package:speak_up/domain/entities/lecture_process/lecture_process.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String usersCollection = 'users';
  final String userSessionsCollection = 'user_sessions';
  final String wordCollection = 'Word'; 

  FirestoreRepository(this._firestore);

  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
   Future<List<Map<String, dynamic>>> getAllWords() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(wordCollection).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching words: $e');
      return [];
    }
  }

  

  Future<String> getUserRole(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    // Kiểm tra document có tồn tại không
    if (!doc.exists) {
      print('Document không tồn tại với ID: $userId');
      return 'user'; // Trả về giá trị mặc định
    }

    // Kiểm tra field role có tồn tại không
    if (!doc.data()!.containsKey('role')) {
      print('Field "role" không tồn tại trong document');
      return 'user';
    }

    return doc.get('role') ?? 'user';
  }

  Future<void> updateLoginTimestamp(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLogoutTimestamp(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLogoutAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getTime() async {
    try {
      final QuerySnapshot userSnapshot =
          await _firestore.collection(usersCollection).orderBy('name').get();

      List<Map<String, dynamic>> users = [];

      for (var doc in userSnapshot.docs) {
        // Get the latest session for this user
        final latestSession = await _firestore
            .collection(userSessionsCollection)
            .where('userId', isEqualTo: doc.id)
            .orderBy('loginTime', descending: true)
            .limit(1)
            .get();

        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        userData['id'] = doc.id;

        if (latestSession.docs.isNotEmpty) {
          final sessionData = latestSession.docs.first.data();
          final loginTime = (sessionData['loginTime'] as Timestamp).toDate();
          final logoutTime = sessionData['logoutTime'] != null
              ? (sessionData['logoutTime'] as Timestamp).toDate()
              : null;

          userData['lastLoginTime'] = loginTime;
          userData['lastLogoutTime'] = logoutTime;
          userData['isCurrentlyLoggedIn'] = logoutTime == null;

          if (logoutTime == null) {
            // Calculate session duration if user is still logged in
            final duration = DateTime.now().difference(loginTime);
            userData['currentSessionDuration'] = duration;
          }
        }

        users.add(userData);
      }

      return users;
    } catch (e) {
      print('Error getting users: $e');
      throw e;
    }
  }

  // Add new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(usersCollection).add(userData);
    } catch (e) {
      print('Error adding user: $e');
      throw e;
    }
  }

  // Update existing user
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update(userData);
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user sessions first
      final sessions = await _firestore
          .collection(userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var session in sessions.docs) {
        await session.reference.delete();
      }

      // Then delete the user
      await _firestore.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      throw e;
    }
  }

  // Record user login
  Future<void> recordUserLogin(String userId) async {
    try {
      await _firestore.collection(userSessionsCollection).add({
        'userId': userId,
        'loginTime': FieldValue.serverTimestamp(),
        'deviceInfo': await _getDeviceInfo(),
      });
    } catch (e) {
      print('Error recording login: $e');
      throw e;
    }
  }

  // Record user logout
  Future<void> recordUserLogout(String userId) async {
    try {
      // Find the latest active session for this user
      final activeSession = await _firestore
          .collection(userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('logoutTime', isNull: true)
          .orderBy('loginTime', descending: true)
          .limit(1)
          .get();

      if (activeSession.docs.isNotEmpty) {
        await activeSession.docs.first.reference.update({
          'logoutTime': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error recording logout: $e');
      throw e;
    }
  }

  // Get user's total session time today
  Future<Duration> getUserTodaySessionTime(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final sessions = await _firestore
          .collection(userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('loginTime', isGreaterThanOrEqualTo: startOfDay)
          .get();

      Duration totalDuration = Duration.zero;

      for (var session in sessions.docs) {
        final data = session.data();
        final loginTime = (data['loginTime'] as Timestamp).toDate();
        final logoutTime = data['logoutTime'] != null
            ? (data['logoutTime'] as Timestamp).toDate()
            : DateTime.now();

        totalDuration += logoutTime.difference(loginTime);
      }

      return totalDuration;
    } catch (e) {
      print('Error calculating session time: $e');
      throw e;
    }
  }

   Future<Map<String, dynamic>> _getDeviceInfo() async {
 
    return {
      'platform': 'Flutter',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> saveUserData(User user, {String role = 'user'}) async {
    print("Saving user data for: ${user.uid}");
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'role': role,
      };
      print("Saving user data to collection: users, Document ID: ${user.uid}");

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      print("User data saved successfully");
    } catch (e) {
      print("Failed to save user data: $e");
    }
  }

  Future<void> updateLogoutTime(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogoutAt': FieldValue.serverTimestamp(), // Thời gian đăng xuất
      });
      print("User logout time updated successfully");
    } catch (e) {
      print("Failed to update logout time: $e");
    }
  }

  Future<void> calculateUsageTime(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final lastLoginAt = (userDoc['lastLoginAt'] as Timestamp?)?.toDate();
      final lastLogoutAt = (userDoc['lastLogoutAt'] as Timestamp?)?.toDate();

      if (lastLoginAt != null && lastLogoutAt != null) {
        final duration = lastLogoutAt.difference(lastLoginAt);
        print("Time spent in app: ${duration.inMinutes} minutes");
      } else {
        print("Login or logout time not available");
      }
    } else {
      print("User document does not exist");
    }
  }

  Future<void> updateUserActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final today =
          DateTime.now().toIso8601String().split('T')[0]; // Ngày hiện tại

      // Lấy document của người dùng
      DocumentReference userActivityRef =
          _firestore.collection('user_activity').doc(userId);

      // Cập nhật thông tin
      await userActivityRef.set({
        'userId': userId,
        'accessDates': FieldValue.arrayUnion([today]), // Thêm ngày truy cập
        'totalHours': FieldValue.increment(1) // Tăng số giờ
      }, SetOptions(merge: true)); // Sử dụng merge để không ghi đè document
    }
  }

  Future<Map<String, dynamic>> getUserActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot =
          await _firestore.collection('user_activity').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return {
          'daysVisited': (data?['accessDates'] as List<dynamic>)?.length ?? 0,
          'totalHours': data?['totalHours'] ?? 0,
        };
      }
    }
    return {
      'daysVisited': 0,
      'totalHours': 0,
    };
  }

  Future<void> updateDisplayName(String name, String uid) async {
    await _firestore.collection('users').doc(uid).update({'name': name});
  }

  Future<void> updateEmail(String email, String uid) async {
    await _firestore.collection('users').doc(uid).update({'email': email});
  }

  Future<List<String>> getYoutubePlaylistIDList() async {
    final youtubePlaylistSnapshot =
        await _firestore.collection('youtube_playlists').get();
    List<String> youtubePlaylistIDs = [];
    for (var docSnapshot in youtubePlaylistSnapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      String youtubePlaylistID = data['PlaylistID'];
      youtubePlaylistIDs.add(youtubePlaylistID);
    }
    return youtubePlaylistIDs;
  }

  Future<void> updateIdiomProgress(LectureProcess process) async {
    final snapshot = await _firestore
        .collection('idiom_process')
        .where('IdiomTypeID', isEqualTo: process.lectureID)
        .where('UserID', isEqualTo: process.uid)
        .get();
    //check if idiom process exists
    if (snapshot.docs.isEmpty) {
      //if not exists, create new idiom process
      await _firestore.collection('idiom_process').add({
        'Progress': process.progress,
        'IdiomTypeID': process.lectureID,
        'UserID': process.uid,
      });
    } else {
      //if exists, update process
      await _firestore
          .collection('idiom_process')
          .doc(snapshot.docs.first.id)
          .update({'Progress': process.progress});
    }
  }

  Future<void> updatePhrasalVerbProgress(LectureProcess input) async {
    final snapshot = await _firestore
        .collection('phrasal_verb_process')
        .where('PhrasalVerbTypeID', isEqualTo: input.lectureID)
        .where('UserID', isEqualTo: input.uid)
        .get();
    //check if phrasal verb process exists
    if (snapshot.docs.isEmpty) {
      //if not exists, create new phrasal verb process
      await _firestore.collection('phrasal_verb_process').add({
        'Progress': input.progress,
        'PhrasalVerbTypeID': input.lectureID,
        'UserID': input.uid,
      });
    } else {
      //if exists, update process
      await _firestore
          .collection('phrasal_verb_process')
          .doc(snapshot.docs.first.id)
          .update({'Progress': input.progress});
    }
  }

  Future<void> updatePatternProgress(LectureProcess input) async {
    final snapshot = await _firestore
        .collection('pattern_process')
        .where('PatternID', isEqualTo: input.lectureID)
        .where('UserID', isEqualTo: input.uid)
        .get();
    //check if pattern process exists
    if (snapshot.docs.isEmpty) {
      //if not exists, create new pattern process
      await _firestore.collection('pattern_process').add({
        'PatternID': input.lectureID,
        'UserID': input.uid,
      });
    }
  }

  Future<void> updatePhoneticProgress(LectureProcess input) async {
    final snapshot = await _firestore
        .collection('phonetic_process')
        .where('UserID', isEqualTo: input.uid)
        .where('PhoneticID', isEqualTo: input.lectureID)
        .get();
    //check if phonetic process exists
    if (snapshot.docs.isEmpty) {
      //if not exists, create new phonetic process
      await _firestore.collection('phonetic_process').add({
        'PhoneticID': input.lectureID,
        'UserID': input.uid,
      });
    }
  }

  Future<List<int>> getPhoneticDoneList(String uid) async {
    final snapshot = await _firestore
        .collection('phonetic_process')
        .where('UserID', isEqualTo: uid)
        .get();
    List<int> phoneticDoneList = [];
    for (var docSnapshot in snapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      int phoneticID = data['PhoneticID'];
      phoneticDoneList.add(phoneticID);
    }
    return phoneticDoneList;
  }

  Future<void> updateExpressionProgress(LectureProcess input) async {
    final snapshot = await _firestore
        .collection('expression_process')
        .where('ExpressionID', isEqualTo: input.lectureID)
        .where('UserID', isEqualTo: input.uid)
        .get();
    //check if expression process exists
    if (snapshot.docs.isEmpty) {
      //if not exists, create new expression process
      await _firestore.collection('expression_process').add({
        'ExpressionID': input.lectureID,
        'UserID': input.uid,
      });
    }
  }

  Future<List<int>> getExpressionDoneList() async {
    final snapshot = await _firestore.collection('expression_process').get();
    List<int> expressionDoneList = [];
    for (var docSnapshot in snapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      int expressionID = data['ExpressionID'];
      expressionDoneList.add(expressionID);
    }
    return expressionDoneList;
  }

  Future<List<int>> getPatternDoneList(String uid) async {
    final snapshot = await _firestore
        .collection('pattern_process')
        .where('UserID', isEqualTo: uid)
        .get();
    List<int> patternDoneList = [];
    for (var docSnapshot in snapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      int patternID = data['PatternID'];
      patternDoneList.add(patternID);
    }
    return patternDoneList;
  }

  Future<int> getIdiomProgress(int idiomTypeID, String uid) async {
    final snapshot = await _firestore
        .collection('idiom_process')
        .where('IdiomTypeID', isEqualTo: idiomTypeID)
        .where('UserID', isEqualTo: uid)
        .get();
    if (snapshot.docs.isEmpty) {
      return 0;
    } else {
      return snapshot.docs.first['Progress'];
    }
  }

  Future<int> getPhrasalVerbProgress(int phrasalVerbTypeID, String uid) async {
    final snapshot = await _firestore
        .collection('phrasal_verb_process')
        .where('PhrasalVerbTypeID', isEqualTo: phrasalVerbTypeID)
        .where('UserID', isEqualTo: uid)
        .get();
    if (snapshot.docs.isEmpty) {
      return 0;
    } else {
      return snapshot.docs.first['Progress'];
    }
  }

  Future<void> addFlashCard(FlashCard flashCard, String uid) async {
    //check contains
    final snapshot = await _firestore
        .collection('flash_cards')
        .where('FlashCardID', isEqualTo: flashCard.flashcardID)
        .where('FrontText', isEqualTo: flashCard.frontText)
        .where('UserID', isEqualTo: uid)
        .get();
    if (snapshot.docs.isEmpty) {
      //if not exists, add new flash card
      await _firestore.collection('flash_cards').add({
        'FlashCardID': flashCard.flashcardID,
        'FrontText': flashCard.frontText,
        'BackText': flashCard.backText,
        'BackTranslation': flashCard.backTranslation,
        'UserID': uid,
      });
    }
  }

  Future<List<FlashCard>> getFlashCardList(String uid) async {
    final snapshot = await _firestore
        .collection('flash_cards')
        .where('UserID', isEqualTo: uid)
        .get();
    List<FlashCard> flashCardList = [];
    for (var docSnapshot in snapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      FlashCard flashCard = FlashCard.fromJson(data);
      flashCardList.add(flashCard);
    }
    return flashCardList;
  }

  Future<void> updateMessages(
      List<Map<String, dynamic>> messagesMap, String uid) {
    return _firestore
        .collection('messages')
        .doc(uid)
        .set({'messages': messagesMap});
  }

  Future<List<Map<String, dynamic>>> getMessages(String uid) async {
    final snapshot = await _firestore.collection('messages').doc(uid).get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> messagesMap = [];
      for (var message in snapshot.data()!['messages']) {
        messagesMap.add(message);
      }

      // if length > 50, then just get last 50 messages
      return messagesMap.length > 50
          ? messagesMap.sublist(messagesMap.length - 50)
          : messagesMap;
    } else {
      return [];
    }
  }
}
