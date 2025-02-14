import 'package:get/get.dart';

class GroupChatController extends GetxController {
  RxList<String> selectedUsers = <String>[].obs;
  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;

  RxString image = "".obs;
  RxString groupName = "".obs;
  RxList<dynamic> members = <dynamic>[].obs;

  void toggleUserSelection(String userId) {
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
  }
}
