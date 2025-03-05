import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/pages/chat/show_group.dart';
import 'package:mithc_koko_chat_app/pages/chat/user_page.dart';

class ChatGroupTabLayout extends StatelessWidget {
  ChatGroupTabLayout({super.key});

  final RxBool isGroupTab = false.obs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: Colors.black),
                insets: EdgeInsets.symmetric(horizontal: 30),
              ),
              onTap: (index) {
                isGroupTab.value = index == 1; // 0 for "Chat", 1 for "Groups"
              },
              tabs: [
                Tab(text: "C H A T"),
                Tab(text: "G R O U P S"),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            UsersPage(),
            ShowGroup(),
          ],
        ),
      ),
    );
  }
}
