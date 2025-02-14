import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String userId;
  final String? imgUrl;
  final void Function()? onTap;

  const UserTile(
      {super.key,
      required this.text,
      required this.onTap,
      required this.userId,
      required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = FirebaseAuth.instance.currentUser!.uid == userId;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Avatar or Icon
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              padding: const EdgeInsets.all(0.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(60),
                  image: imgUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(imgUrl!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: CachedNetworkImageProvider(
                              'https://www.gravatar.com/avatar/?d=identicon'),
                          fit: BoxFit.cover,
                        ),
                ),
                child: imgUrl == null
                    ? Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Username and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCurrentUser)
                    Text(
                      "You",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ThemeProvider().isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                ],
              ),
            ),

            // Add an optional trailing action/icon (if needed)
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSecondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
