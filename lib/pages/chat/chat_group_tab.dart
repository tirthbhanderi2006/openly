import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/pages/chat/create_group.dart';
import 'package:mithc_koko_chat_app/pages/chat/show_group.dart';
import 'package:mithc_koko_chat_app/pages/chat/user_page.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class ChatGroupController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var tabIndex = 0.obs; // Track current tab index

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      tabIndex.value = tabController.index; // Update index on swipe
    });
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class ChatGroupTabLayout extends StatelessWidget {
  ChatGroupTabLayout({super.key});

  final ChatGroupController controller = Get.put(ChatGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "C H A T S",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [
          Obx(() => controller.tabIndex.value == 1
              ? IconButton(
                  icon: const Icon(Icons.group_add),
                  tooltip: "Create Group",
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideUpNavigationAnimation(child: CreateGroupScreen()),
                    );
                  },
                )
              : const SizedBox.shrink()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: controller.tabController, // Attach controller
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.black),
              insets: EdgeInsets.symmetric(horizontal: 30),
            ),
            tabs: const [
              Tab(text: "C H A T"),
              Tab(text: "G R O U P S"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController, // Attach controller
        children: const [
          UsersPage(),
          ShowGroup(),
        ],
      ),
    );
  }
}
