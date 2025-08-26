import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:sixam_mart/features/details/screen/media/video/video_player_screen.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final List<Media> videoUrl;

  const VideoThumbnailWidget({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late VideoPlayerController _controller;
  bool isThumbnailLoaded = false;

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.network(widget.videoUrl)
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl[0].imageFullUrl!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            isThumbnailLoaded = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDialog(
              videoUrls: widget.videoUrl,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        color: const Color.fromARGB(164, 180, 178, 178),
        width: double.infinity,
        height: double.infinity,
        child: isThumbnailLoaded
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayer(_controller), // Shows first frame
              )
            : Shimmer(
                duration: const Duration(seconds: 2),
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
                // child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Container(
                //         // width: double.infinity,
                //         // height: double.infinity,
                //         decoration: BoxDecoration(
                //           borderRadius: const BorderRadius.vertical(
                //               top: Radius.circular(Dimensions.radiusSmall)),
                //           color: Theme.of(context).shadowColor,
                //         ),
                //       ),
                //       const SizedBox(width: Dimensions.paddingSizeSmall),
                //       Expanded(
                //         child: Padding(
                //           padding: const EdgeInsets.all(
                //               Dimensions.paddingSizeExtraSmall),
                //           child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               children: [
                //                 Container(
                //                     height: 15,
                //                     width: 200,
                //                     color: Theme.of(context).shadowColor),
                //                 const SizedBox(height: 5),
                //                 Container(
                //                     height: 10,
                //                     width: 130,
                //                     color: Theme.of(context).shadowColor),
                //                 const SizedBox(height: 5),
                //                 Row(
                //                   children: List.generate(5, (index) {
                //                     return Icon(Icons.star,
                //                         color: Theme.of(context).shadowColor,
                //                         size: 15);
                //                   }),
                //                 ),
                //               ]),
                //         ),
                //       ),
                //     ]),
              ),
        // Loading indicator
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
