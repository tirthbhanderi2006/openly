import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  var searchResults = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  void fetchUsers(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 1000));
    try {
      // Lowercase query for case-insensitive search
      String lowercaseQuery = query.trim().toLowerCase();
      // Fetch all users
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .get();

      // Filter results based on name or email containing the query
      searchResults.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) =>
      (user['name']?.toString().toLowerCase().contains(lowercaseQuery) ?? false) ||
          (user['email']?.toString().toLowerCase().contains(lowercaseQuery) ?? false)
      ).toList();
      // print(searchResults.length);
    } catch (e) {
      print("Error fetching users: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }}
