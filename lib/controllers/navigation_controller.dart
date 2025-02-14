import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController with WidgetsBindingObserver {
  RxInt currentIndex = 0.obs;

  var isKeyboardOpen = false.obs;
  var lastScrollPosition = 0.0.obs;
  var isBottomBarVisible = true.obs;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    isKeyboardOpen.value = bottomInset > 0;
  }

  void changeIndex(value) {
    currentIndex.value = value;
  }

  void updateScrollVisibility(double scrollPosition) {
    // Show bottom bar when scrolling up, hide when scrolling down
    if (scrollPosition > lastScrollPosition.value &&
        isBottomBarVisible.value &&
        scrollPosition > 100) {
      isBottomBarVisible.value = false;
    } else if (scrollPosition < lastScrollPosition.value &&
        !isBottomBarVisible.value) {
      isBottomBarVisible.value = true;
    }
    lastScrollPosition.value = scrollPosition;
  }
}
