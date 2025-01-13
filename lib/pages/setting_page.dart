import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import 'blocked_users_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("S E T T I N G S",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dark Mode label
                      const Text(
                        "Dark Mode",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // Switch toggle
                      Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dark Mode label
                      const Text(
                        "Blocked users",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // Switch toggle
                      IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => BlockedUsersPage(),)), icon: Icon(Icons.block))
                    ],
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
