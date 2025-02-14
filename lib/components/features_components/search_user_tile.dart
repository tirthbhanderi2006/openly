import 'package:cached_network_image/cached_network_image.dart';
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
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withOpacity(0.15), // Soft glass effect
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// **User Avatar**
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl:
                      imgUrl ?? 'https://www.gravatar.com/avatar/?d=identicon',
                  placeholder: (context, url) => const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.person_off,
                    size: 30,
                    color: Colors.red,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// **User Info**
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onBackground.withOpacity(0.7),
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
                          color: colorScheme.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// **Trailing Icon**
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.onSecondary.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
