import 'package:flutter/material.dart';

class TestProfilePage extends StatefulWidget {
  const TestProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<TestProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock profile data
  final profile = {
    'username': 'janedoe',
    'name': 'Jane Doe',
    'bio': 'Digital creator | Photography enthusiast 📸\nExploring the world one photo at a time ✈️',
    'posts': 342,
    'followers': '15.4K',
    'following': 891,
  };

  // Mock posts data
  final List<Map<String, dynamic>> posts = List.generate(
    9,
    (index) => {
      'id': index,
      'imageUrl': 'https://picsum.photos/300/300?random=$index',
      'likes': (1000 * index % 500).toString(),
      'comments': (100 * index % 50).toString(),
    },
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          profile['username']!.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Stats
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/150/150',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('Posts', profile['posts'].toString()),
                            _buildStatColumn('Followers', profile['followers']!.toString()),
                            _buildStatColumn('Following', profile['following'].toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and Bio
                  Text(
                    profile['name']!.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(profile['bio']!.toString()),
                  const SizedBox(height: 16),
                  
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on)),
                Tab(icon: Icon(Icons.bookmark_border)),
              ],
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
            ),

            // Tab Views
            SizedBox(
              height: MediaQuery.of(context).size.width, // Make it square
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Posts Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostTile(posts[index]);
                    },
                  ),
                  
                  // Saved Posts
                  const Center(
                    child: Text(
                      'No saved posts yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPostTile(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post['imageUrl'],
            fit: BoxFit.cover,
          ),
          // Hover overlay (Note: In mobile, this will show on tap)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            post['likes'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            post['comments'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}