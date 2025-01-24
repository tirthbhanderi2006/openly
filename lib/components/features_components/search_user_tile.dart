import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchUserTile extends StatelessWidget {
  final String userName;
  final String userId;
  final String? imgUrl;
  final String email;
  final void Function()? onTap;

  const SearchUserTile({
    super.key,
    required this.userName,
    required this.userId,
    required this.imgUrl,
    required this.email,
    required this.onTap,
  });

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
                          image: NetworkImage(imgUrl!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: NetworkImage(
                              'https://www.gravatar.com/avatar/?d=identicon'),
                          fit: BoxFit.cover,
                        ),
                ),
                child: imgUrl == null
                    ? Icon(
                        Icons.person,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Username and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSecondary.withOpacity(0.8),
                    ),
                  ),
                  if (isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "You",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Optional trailing action/icon
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
