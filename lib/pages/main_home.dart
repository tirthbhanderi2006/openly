import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_bottombar.dart';
import 'package:mithc_koko_chat_app/pages/chat/chat_group_tab.dart';
import 'package:mithc_koko_chat_app/pages/features/create_post_page.dart';
import 'package:mithc_koko_chat_app/pages/features/search_page.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';

import '../controllers/navigation_controller.dart';

class MainHome extends StatelessWidget {
  MainHome({super.key});
  final NavigationController _navigationController =
      Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomePage(),
      SearchPage(),
      CreatePostPage(),
      ProfilePage(userId: FirebaseAuth.instance.currentUser!.uid),
      // UsersPage()
      ChatGroupTabLayout()
    ];

    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: false,
        body: Obx(() => pages[_navigationController.currentIndex.value]),
        // to test crash errors in firebase
        // floatingActionButton: FloatingActionButton(onPressed: () => throw Exception('App crashed intentionally')),
        // floatingActionButton: FloatingActionButton(onPressed: () => throw TlsException()),

        bottomNavigationBar: Obx(
          () => _navigationController.isKeyboardOpen.value
              ? SizedBox.shrink()
              : MyBottomBar(),
        ));
  }
}
