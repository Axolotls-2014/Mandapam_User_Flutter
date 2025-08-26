import 'package:flutter/material.dart';
import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:video_player/video_player.dart';

class VideoDialog extends StatefulWidget {
  final List<Media> videoUrls;
  final int initialIndex; // Start at a specific video index

  const VideoDialog(
      {super.key, required this.videoUrls, this.initialIndex = 0});

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  late PageController _pageController;
  late List<VideoPlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize controllers for all videos
    _controllers = widget.videoUrls
        .map((url) =>
            VideoPlayerController.networkUrl(Uri.parse(url.imageFullUrl!))
              ..initialize().then((_) {
                setState(() {});
              }))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: Border.all(),
      backgroundColor: Colors.black,
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.zero, // Make it full screen
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.videoUrls.length,
            itemBuilder: (context, index) {
              final controller = _controllers[index];

              return GestureDetector(
                onTap: () {
                  // Play/Pause video on tap
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Center(
                  child: controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        )
                      : const CircularProgressIndicator(),
                ),
              );
            },
            onPageChanged: (index) {
              for (var c in _controllers) {
                c.pause(); // Pause all videos
              }
              _controllers[index].play(); // Play the new one
            },
          ),

          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                for (var c in _controllers) {
                  c.dispose();
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
