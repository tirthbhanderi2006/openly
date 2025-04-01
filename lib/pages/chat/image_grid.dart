import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Images"),
        centerTitle: true,
      ),
      body: imageUrls.isEmpty
          ? const Center(
              child: Text(
                "No images shared yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: imageUrls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, SlideRightPageTransition(child: FullScreenImage(imageUrl: imageUrls[index])));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
