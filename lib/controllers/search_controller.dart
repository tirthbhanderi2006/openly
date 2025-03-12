import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  var searchResults = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchPerformed = false.obs;
  var hasSearched = false.obs;


  void fetchUsers(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    // await Future.delayed(Duration(milliseconds: 1000));

    try {
      String lowercaseQuery = query.trim().toLowerCase();

      // Get current user ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch blocked user IDs
      QuerySnapshot blockedSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("BlockedUsers")
          .get();

      List<String> blockedUserIds = blockedSnapshot.docs
          .map((doc) => doc.id)
          .toList(); // Extract blocked user IDs

      // Fetch all users
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("users").get();

      // Filter results based on name, email and remove blocked users
      searchResults.value = snapshot.docs
          .map((doc) {
        var user = doc.data() as Map<String, dynamic>;
        user['id'] = doc.id; // Ensure user ID is included
        return user;
      })
          .where((user) =>
      !blockedUserIds.contains(user['id']) && // Exclude blocked users
          ((user['name']
              ?.toString()
              .toLowerCase()
              .contains(lowercaseQuery) ??
              false) ||
              (user['email']
                  ?.toString()
                  .toLowerCase()
                  .contains(lowercaseQuery) ??
                  false)))
          .toList();
    } catch (e) {
      print("Error fetching users: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // optimized but dont works in some cases !!
  /*
  void fetchUsers(String query) async {
  if (query.isEmpty) return;

  isLoading.value = true;
  await Future.delayed(Duration(milliseconds: 1000));
  
  try {
    String lowercaseQuery = query.trim().toLowerCase();

    // Query for users where name matches
    QuerySnapshot nameSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('name', isLessThanOrEqualTo: lowercaseQuery + '\uf8ff')
        .get();

    // Query for users where email matches
    QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('email', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('email', isLessThanOrEqualTo: lowercaseQuery + '\uf8ff')
        .get();

    // Merge results while avoiding duplicates
    Set<String> uniqueUserIds = {};
    List<Map<String, dynamic>> results = [];

    for (var doc in nameSnapshot.docs) {
      if (!uniqueUserIds.contains(doc.id)) {
        uniqueUserIds.add(doc.id);
        results.add(doc.data() as Map<String, dynamic>);
      }
    }

    for (var doc in emailSnapshot.docs) {
      if (!uniqueUserIds.contains(doc.id)) {
        uniqueUserIds.add(doc.id);
        results.add(doc.data() as Map<String, dynamic>);
      }
    }

    searchResults.value = results;
  } catch (e) {
    print("Error fetching users: $e");
    searchResults.clear();
  } finally {
    isLoading.value = false;
  }
}

  */
}
