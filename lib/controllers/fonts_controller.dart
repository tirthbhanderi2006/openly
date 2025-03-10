import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class FontController extends GetxController {
  final box = GetStorage();
  List<String> availableFonts = GoogleFonts.asMap().keys.toList();
  var filteredFonts = <String>[].obs;
  RxString selectedFont = 'Recursive'.obs; // Default font

  @override
  void onInit() {
    super.onInit();
    selectedFont.value = box.read('selectedFont') ?? 'Recursive';
    filteredFonts.assignAll(availableFonts);
  }

  void updateFont({required String font}) {
    selectedFont.value = font;
    box.write('selectedFont', font);

    // show the resstart snakbar
    Get.snackbar(
      'Font Changed',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.isDarkMode
          ? Colors.grey[850]!.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Get.isDarkMode ? Colors.black38 : Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        )
      ],
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.all(16),
      duration: Duration(minutes: 30),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      icon: Icon(
        FlutterRemix.restart_line,
        color: Colors.blue,
        size: 36,
      ),
      titleText: Text(
        'Font Changed Successfully',
        style: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text(
            'Please restart the app to apply your new font settings.',
            style: TextStyle(
              color: Get.isDarkMode
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black54,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.closeCurrentSnackbar();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'LATER',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Restart.restartApp(); //restarting the app to apply changes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FlutterRemix.restart_line, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'RESTART NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      forwardAnimationCurve: Curves.easeOutQuart,
      reverseAnimationCurve: Curves.easeInQuart,
      animationDuration: Duration(milliseconds: 400),
    );
  }

  // function for searching fonts
  void filterFonts(String query) {
    if (query.isEmpty) {
      filteredFonts.assignAll(availableFonts);
    } else {
      filteredFonts.assignAll(
        availableFonts
            .where((font) => font.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}
