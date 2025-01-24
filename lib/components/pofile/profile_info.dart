import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/controllers/profile_controller.dart';
import 'package:mithc_koko_chat_app/pages/profile/followers_list.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class UserProfileStats extends StatelessWidget {
  final String name;
  final List<dynamic> followers;
  final List<dynamic> following;

  const UserProfileStats({
    super.key,
    required this.name,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Text(
              name.toString() ?? 'user name', // Username or fallback
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14, // Font size for readability
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10), // Spacing between username and stats
          // Stats: Followers, Following, and Posts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        following: List<String>.from(following ?? []),
                        followers: List<String>.from(followers ?? []),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
              _buildStatItem(
                context: context,
                label: "Following",
                count: profileController.followingCount.value,
                onTap: () {
                  Navigator.push(
                    context,
                    SlideUpNavigationAnimation(
                      child: FollowersList(
                        following: List<String>.from(following ?? []),
                        followers: List<String>.from(followers ?? []),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
              _buildStatItem(
                context: context,
                label: "Posts",
                count: profileController.posts.length,
                onTap: () {}, // Add functionality if needed
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 16, // Font size for stats count
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Font size for stats label
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
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
