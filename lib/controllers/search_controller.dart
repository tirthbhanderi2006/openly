import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  var searchResults = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  void fetchUsers(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 1500));

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: query)
          .get();

      searchResults.value =
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching users: $e");
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
