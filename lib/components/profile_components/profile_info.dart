import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/profile_components/profile_picture.dart';
import 'package:mithc_koko_chat_app/controllers/profile_controller.dart';
import 'package:mithc_koko_chat_app/pages/profile/followers_list.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
class UserProfileStats extends StatelessWidget {
  final String name;
  final String userId;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int postsCount;
  final String profileImageUrl;
  final String email;

  const UserProfileStats({
    super.key,
    required this.userId,
    required this.name,
    required this.followers,
    required this.following,
    required this.postsCount,
    required this.profileImageUrl,
  required this.email
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        children: [
          // Centered Profile Picture
          Center(
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              child:  ProfilePicture(
                  profilePicUrl: profileImageUrl ?? ''),
            ),
          ),

          const SizedBox(height: 12),

          // Username
          Center(
            child: Text(
              name.isNotEmpty ? name : 'User',
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
          ),

          // User ID
          Center(
            child: Text(
              "$email",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context: context,
                label: "Followers",
                count: profileController.followersCount.value,
                onTap: () {
                  Navigator.push(
                    context,
                    SlideUpNavigationAnimation(
                      child: FollowersList(
                        following: List<String>.from(following),
                        followers: List<String>.from(followers),
                      ),
                    ),
                  );
                },
              ),
              _buildStatDivider(context),
              _buildStatItem(
                context: context,
                label: "Following",
                count: profileController.followingCount.value,
                onTap: () {
                  Navigator.push(
                    context,
                    SlideUpNavigationAnimation(
                      child: FollowersList(
                        following: List<String>.from(following),
                        followers: List<String>.from(followers),
                      ),
                    ),
                  );
                },
              ),
              _buildStatDivider(context),
              _buildStatItem(
                context: context,
                label: "Posts",
                count: postsCount,
                onTap: () {/*navigate to all post page */},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}

//                  this is code is previously used in the profile_info.dart file if needed you can use it

// Container(
//   height: 120,
//   width: 120,
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     image: userDetails['profilePic'] != null && userDetails['profilePic']!.isNotEmpty
//         ? DecorationImage(
//       image: NetworkImage(userDetails['profilePic']),
//       fit: BoxFit.cover,
//     )
//         : const DecorationImage(
//       image: NetworkImage('https://www.gravatar.com/avatar/?d=identicon'),
//       fit: BoxFit.cover,
//     ),
//   ),
// ),
// Padding and Profile Info
// Padding(
//   padding: const EdgeInsets.symmetric(
//       vertical: 16.0, horizontal: 20.0),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Username
//       Padding(
//         padding: const EdgeInsets.only(left: 3.0),
//         child: Text(
//           userDetails['name'] ??
//               'user name', // Use the username from userDetails or fallback to a default
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize:
//                 14, // Adjusted font size for better readability
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//         ),
//       ),
//       const SizedBox(
//           height:
//               10), // Reduced gap between username and stats
//       // Stats: Followers, Following, and Posts
//       Row(
//         mainAxisAlignment: MainAxisAlignment
//             .spaceBetween, // Ensures equal spacing between stats
//         children: [
//           // Followers
//           Padding(
//             padding: const EdgeInsets.only(right: 10.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     SlideUpNavigationAnimation(
//                       child: FollowersList(
//                         following: List<String>.from(
//                             userDetails['following'] ??
//                                 []),
//                         followers: List<String>.from(
//                                 userDetails[
//                                     'followers']) ??
//                             [],
//                       ),
//                     ));
//               },
//               child: Column(
//                 children: [
//                   Obx(() => Text(
//                         "${profileController.followersCount}",
//                         style: TextStyle(
//                           fontSize:
//                               16, // Adjusted font size for consistency
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary,
//                         ),
//                       )),
//                   const SizedBox(height: 5),
//                   Text(
//                     "Followers",
//                     style: TextStyle(
//                       fontSize:
//                           12, // Slightly smaller font for labels
//                       color: Theme.of(context)
//                           .colorScheme
//                           .inversePrimary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Following
//           Padding(
//             padding: const EdgeInsets.only(right: 10.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     SlideUpNavigationAnimation(
//                       child: FollowersList(
//                         following: List<String>.from(
//                             userDetails['following'] ??
//                                 []),
//                         followers: List<String>.from(
//                                 userDetails[
//                                     'followers']) ??
//                             [],
//                       ),
//                     ));
//               },
//               child: Column(
//                 children: [
//                   Obx(() => Text(
//                         "${profileController.followingCount}",
//                         style: TextStyle(
//                           fontSize:
//                               16, // Consistent font size
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary,
//                         ),
//                       )),
//                   const SizedBox(height: 5),
//                   Text(
//                     "Following",
//                     style: TextStyle(
//                       fontSize:
//                           12, // Consistent label size
//                       color: Theme.of(context)
//                           .colorScheme
//                           .inversePrimary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Posts
//           Column(
//             children: [
//               Obx(() => Text(
//                     "${profileController.posts.length}",
//                     style: TextStyle(
//                       fontSize:
//                           16, // Consistent font size
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primary,
//                     ),
//                   )),
//               const SizedBox(height: 5),
//               Text(
//                 "Posts",
//                 style: TextStyle(
//                   fontSize: 12, // Consistent label size
//                   color: Theme.of(context)
//                       .colorScheme
//                       .inversePrimary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   ),
// ),