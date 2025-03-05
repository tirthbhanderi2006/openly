import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';

class ChatBackgroundController extends GetxController {
  RxString backgroundImagePath = RxString('');
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadBackgroundImage();
  }

  Future<void> loadBackgroundImage() async {
    try {
      final path = box.read('chatBackgroundPath') ?? '';
      backgroundImagePath.value = path;
    } catch (e) {
      print('Error loading background image: $e');
    }
  }

  Future<void> updateBackgroundImage(String newPath) async {
    backgroundImagePath.value = newPath;
    await box.write('chatBackgroundPath', newPath);
  }

  Future<void> pickAndSaveBackgroundImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final appDir = await getApplicationDocumentsDirectory();

      final fileName =
          'chat_background_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');

      await updateBackgroundImage(newImage.path);

      Get.snackbar(
        'Success',
        'Chat background saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save background: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeBackground() async {
    if (backgroundImagePath.value.isNotEmpty) {
      backgroundImagePath.value = "";
      await box.remove('chatBackgroundPath');
      Get.snackbar("Chat", "Background removed",
          // snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.green);
    } else {
      Get.snackbar("Chat", "Background is already removed",
      // snackPosition: SnackPosition.BOTTOM
      colorText: Colors.white,
      backgroundColor: Colors.green
      );
    }
  }
}
