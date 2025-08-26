// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sixam_mart/api/api_client.dart';
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
// import 'package:sixam_mart/features/details/domain/model/view_media_model.dart';
// import 'package:sixam_mart/features/details/screen/details_screen.dart';
// import 'package:sixam_mart/features/media/functions.dart';
// import 'package:sixam_mart/features/media/view_decorator.dart';
// import 'package:sixam_mart/helper/auth_helper.dart';
// import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
// import 'package:video_player/video_player.dart';
// import 'package:get/get.dart';
//
// class FavoriteListScreen extends StatefulWidget {
//   final SharedPreferences sharedPreferences;
//   final bool fromDashboard;
//   final String selectedEventId;
//
//   FavoriteListScreen({
//     required this.sharedPreferences,
//     required this.selectedEventId,
//     this.fromDashboard = false,
//   });
//
//   @override
//   _FavoriteListScreenState createState() => _FavoriteListScreenState();
// }
//
// class _FavoriteListScreenState extends State<FavoriteListScreen> {
//   late ApiService apiService;
//   List<Map<String, dynamic>>? events;
//   Map<String, dynamic>? selectedEvent;
//   bool isDropdownOpen = false;
//   List<int> eventIds = [];
//   List<String> eventNames = [];
//   bool isLoading = true;
//   String? selectedEventName;
//   int? selectedEventIndex;
//   List<MediaItem> mediaList = [];
//   int? selectedMediaIndex;
//   late AuthController authController;
//   String? globalUserId;
//   Map<int, Map<String, dynamic>> decoratorInfoMap = {};
//
//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService(sharedPreferences: widget.sharedPreferences, apiClient: Get.find<ApiClient>());
//     _fetchUserId().then((_) {
//       if (globalUserId != null) {
//         try {
//           int userId = int.parse(globalUserId!);
//           fetchWishlist(userId);
//         } catch (e) {
//           print("Error: Could not convert globalUserId to int");
//         }
//       }
//     });
//     selectedEventIndex = 0;
//   }
//
//   Future<void> _fetchUserId() async {
//     authController = Get.find<AuthController>();
//     globalUserId = await authController.getUserId();
//
//     if (globalUserId != null) {
//       print("Stored_User_ID: $globalUserId");
//     } else {
//       print("Error: Could not fetch User ID");
//     }
//   }
//
//   // Future<void> fetchWishlist(int userId) async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });
//   //
//   //   final response = await apiService.getWishlist(userId: userId);
//   //
//   //   if (response != null && response['wishlist'] is List) {
//   //     decoratorInfoMap.clear();
//   //     List<MediaItem> allMedia = [];
//   //
//   //     for (var item in response['wishlist']) {
//   //       final decoratorId = item['Decorator']['user_id'];
//   //       decoratorInfoMap[decoratorId] = {
//   //         'name': item['Decorator']['first_name'],
//   //         'last_name': item['Decorator']['last_name'],
//   //         'image_full_url': item['Decorator']['image_full_url'],
//   //       };
//   //
//   //       allMedia.add(MediaItem.fromJson({
//   //         'id': item['media_id'],
//   //         'title': item['media_title'],
//   //         'media_type': item['media_type'],
//   //         'image_full_url': item['image_full_url'],
//   //         'decorator_id': decoratorId,
//   //       }));
//   //     }
//   //
//   //     setState(() {
//   //       mediaList = allMedia;
//   //       isLoading = false;
//   //     });
//   //   } else {
//   //     setState(() {
//   //       mediaList = [];
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//
//   void _showMediaFullScreen(int index) {
//     final media = mediaList[index];
//     final decoratorId = media.decoratorId?.toString() ?? '0';
//     final decoratorInfo = decoratorId != '0' ? decoratorInfoMap[int.parse(decoratorId)] : null;
//
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => FullScreenMediaViewer(
//           mediaList: mediaList,
//           initialIndex: index,
//           sharedPreferences: widget.sharedPreferences,
//           decoratorInfoMap: decoratorInfoMap,
//         ),
//       ),
//     ).then((value) {
//       if (value == true && globalUserId != null) {
//         try {
//           int userId = int.parse(globalUserId!);
//           fetchWishlist(userId);
//         } catch (e) {
//           print("Error: Could not convert globalUserId to int");
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.grey.shade100,
//       appBar: CustomAppBar(title: 'View Media', backButton: widget.fromDashboard ? false : true),
//       body: AuthHelper.isLoggedIn()
//           ? isLoading
//           ? Container(
//         child: Center(
//           child: SizedBox(
//             width: 25,
//             height: 25,
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       )
//           : SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           children: [
//             mediaList.isEmpty
//                 ? Container(
//               height: 350,
//               child: Center(
//                 child: Text(
//                   'No media available',
//                   style: TextStyle(fontSize: 14),
//                 ),
//               ),
//             )
//                 : GridView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
//               itemCount: mediaList.length,
//               itemBuilder: (context, index) {
//                 final media = mediaList[index];
//                 return GestureDetector(
//                   onTap: () {
//                     _showMediaFullScreen(index);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(color: Colors.white),
//                     child: media.mediaType == 'photo'
//                         ? media.imageFullUrl != null
//                         ? Image.network(media.imageFullUrl!, fit: BoxFit.cover)
//                         : Placeholder()
//                         : media.imageFullUrl != null
//                         ? VideoPreviewWidget(videoUrl: media.imageFullUrl!)
//                         : Placeholder(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       )
//           : NotLoggedInScreen(callBack: (value) {
//         setState(() {});
//       }),
//     );
//   }
// }
//
// class VideoPreviewWidget extends StatefulWidget {
//   final String videoUrl;
//
//   VideoPreviewWidget({required this.videoUrl});
//
//   @override
//   _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
// }
//
// class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//           ),
//           child: _controller.value.isInitialized
//               ? ClipRRect(
//             child: SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 child: SizedBox(
//                   width: _controller.value.size.width,
//                   height: _controller.value.size.height,
//                   child: VideoPlayer(_controller),
//                 ),
//               ),
//             ),
//           )
//               : Container(),
//         ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: Icon(
//             Icons.videocam,
//             color: Colors.black.withOpacity(0.6),
//             size: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class FullScreenMediaViewer extends StatefulWidget {
//   final List<MediaItem> mediaList;
//   final int initialIndex;
//   final SharedPreferences sharedPreferences;
//   final Map<int, Map<String, dynamic>> decoratorInfoMap;
//
//   const FullScreenMediaViewer({
//     required this.mediaList,
//     required this.initialIndex,
//     required this.sharedPreferences,
//     required this.decoratorInfoMap,
//   });
//
//   @override
//   _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
// }
//
// class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> with WidgetsBindingObserver {
//   late PageController _pageController;
//   late int currentIndex;
//   VideoPlayerController? _videoController;
//   late ApiService apiService;
//   bool _isLandscape = false;
//   bool _isTitleExpanded = false;
//   bool _isLiked = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: currentIndex);
//     _initializeVideoController();
//     apiService = ApiService(sharedPreferences: widget.sharedPreferences, apiClient: Get.find<ApiClient>());
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _videoController?.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeMetrics() {
//     final orientation = WidgetsBinding.instance.window.physicalSize.aspectRatio;
//     setState(() {
//       _isLandscape = orientation > 1.0;
//     });
//     super.didChangeMetrics();
//   }
//
//   Future<void> _toggleOrientation() async {
//     if (_isLandscape) {
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//     } else {
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ]);
//     }
//   }
//
//   Future<bool> _onWillPop() async {
//     if (_isLandscape) {
//       await _toggleOrientation();
//       return false;
//     }
//     return true;
//   }
//
//   void _initializeVideoController() {
//     if (widget.mediaList[currentIndex].mediaType == 'video' &&
//         widget.mediaList[currentIndex].imageFullUrl != null) {
//       _videoController = VideoPlayerController.network(widget.mediaList[currentIndex].imageFullUrl!)
//         ..initialize().then((_) {
//           if (mounted) {
//             setState(() {});
//             _videoController?.play();
//           }
//         });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final media = widget.mediaList[currentIndex];
//     final String? title = media.title?.trim().isNotEmpty == true ? media.title : 'Media';
//     final bool isVideo = media.mediaType == 'video';
//     final bool hasValidTitle = title != null && title.trim().isNotEmpty;
//
//     final decoratorId = media.decoratorId ?? 0;
//     final decoratorInfo = widget.decoratorInfoMap[decoratorId] ?? {};
//     final decoratorName = decoratorInfo['name'] ?? '';
//     final decoratorLastName = decoratorInfo['last_name'] ?? '';
//     final decoratorImage = decoratorInfo['image_full_url'];
//
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           iconTheme: IconThemeData(color: Colors.white),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () async {
//               if (_isLandscape) {
//                 await _toggleOrientation();
//               } else {
//                 Navigator.of(context).pop();
//               }
//             },
//           ),
//           actions: [
//             if (isVideo)
//               IconButton(
//                 icon: Icon(
//                   _isLandscape ? Icons.screen_lock_portrait : Icons.screen_lock_landscape,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onPressed: _toggleOrientation,
//               ),
//           ],
//         ),
//         body: Stack(
//           children: [
//             PageView.builder(
//               itemCount: widget.mediaList.length,
//               controller: _pageController,
//               physics: BouncingScrollPhysics(),
//               onPageChanged: (index) {
//                 if (mounted) {
//                   setState(() {
//                     currentIndex = index;
//                     _videoController?.dispose();
//                     _videoController = null;
//                     _initializeVideoController();
//                     _isTitleExpanded = false;
//                   });
//                 }
//               },
//               itemBuilder: (context, index) {
//                 final media = widget.mediaList[index];
//                 if (media.mediaType == 'photo' && media.imageFullUrl != null) {
//                   return Center(
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: MediaQuery.of(context).size.height * 0.8,
//                       child: PhotoView(
//                         imageProvider: NetworkImage(media.imageFullUrl!),
//                         initialScale: PhotoViewComputedScale.contained,
//                         minScale: PhotoViewComputedScale.contained * 0.5,
//                         maxScale: PhotoViewComputedScale.covered * 2,
//                         backgroundDecoration: BoxDecoration(color: Colors.black),
//                       ),
//                     ),
//                   );
//                 } else if (media.mediaType == 'video' && media.imageFullUrl != null) {
//                   double _scale = 1.0;
//                   Matrix4 _matrix = Matrix4.identity();
//
//                   return Center(
//                     child: _videoController != null && _videoController!.value.isInitialized
//                         ? Stack(
//                       children: [
//                         Center(
//                           child: SizedBox(
//                             width: MediaQuery.of(context).size.width,
//                             height: _isLandscape
//                                 ? MediaQuery.of(context).size.height * 0.7
//                                 : MediaQuery.of(context).size.height * 0.5,
//                             child: GestureDetector(
//                               onTap: _toggleOrientation,
//                               onScaleStart: (ScaleStartDetails details) {},
//                               onScaleUpdate: (ScaleUpdateDetails details) {
//                                 if (mounted) {
//                                   setState(() {
//                                     _scale = details.scale.clamp(1.0, 3.0);
//                                     _matrix = Matrix4.identity()
//                                       ..scale(_scale, _scale, 1.0);
//                                   });
//                                 }
//                               },
//                               onDoubleTap: () {
//                                 if (mounted) {
//                                   setState(() {
//                                     _scale = 1.0;
//                                     _matrix = Matrix4.identity();
//                                   });
//                                 }
//                               },
//                               child: ClipRect(
//                                 child: Transform(
//                                   transform: _matrix,
//                                   alignment: Alignment.center,
//                                   child: AspectRatio(
//                                     aspectRatio: _videoController!.value.aspectRatio,
//                                     child: VideoPlayer(_videoController!),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         if (!_isLandscape)
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: Container(
//                               color: Colors.black.withOpacity(0.5),
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Column(
//                                 children: [
//                                   LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       return GestureDetector(
//                                         behavior: HitTestBehavior.opaque,
//                                         onPanDown: (details) {
//                                           _seekToPosition(details.localPosition.dx, constraints.maxWidth);
//                                         },
//                                         onPanUpdate: (details) {
//                                           _seekToPosition(details.localPosition.dx, constraints.maxWidth);
//                                         },
//                                         child: Container(
//                                           height: 30,
//                                           alignment: Alignment.center,
//                                           child: VideoProgressIndicator(
//                                             _videoController!,
//                                             allowScrubbing: false,
//                                             padding: EdgeInsets.symmetric(horizontal: 16),
//                                             colors: VideoProgressColors(
//                                               playedColor: Colors.blue,
//                                               bufferedColor: Colors.grey[300]!,
//                                               backgroundColor: Colors.grey[600]!,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       IconButton(
//                                         icon: Icon(Icons.replay_5, color: Colors.white, size: 30),
//                                         onPressed: () {
//                                           _videoController!.seekTo(
//                                             _videoController!.value.position - Duration(seconds: 5),
//                                           );
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: Icon(
//                                           _videoController!.value.isPlaying
//                                               ? Icons.pause
//                                               : Icons.play_arrow,
//                                           color: Colors.white,
//                                           size: 36,
//                                         ),
//                                         onPressed: () {
//                                           if (mounted) {
//                                             setState(() {
//                                               _videoController!.value.isPlaying
//                                                   ? _videoController!.pause()
//                                                   : _videoController!.play();
//                                             });
//                                           }
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: Icon(Icons.forward_5, color: Colors.white, size: 30),
//                                         onPressed: () {
//                                           _videoController!.seekTo(
//                                             _videoController!.value.position + Duration(seconds: 5),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     )
//                         : CircularProgressIndicator(),
//                   );
//                 }
//                 return SizedBox.shrink();
//               },
//             ),
//             Positioned(
//               bottom: isVideo ? (_isLandscape ? 20 : 100) : 20,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 color: Colors.black.withOpacity(0.5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ViewDecorator(
//                                     sharedPreferences: widget.sharedPreferences,
//                                     decoratorId: decoratorId.toString(),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 14,
//                                   backgroundColor: Colors.white,
//                                   backgroundImage: decoratorImage != null
//                                       ? NetworkImage(decoratorImage)
//                                       : null,
//                                   child: decoratorImage == null && decoratorName.isNotEmpty
//                                       ? Text(
//                                     decoratorName[0].toUpperCase(),
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )
//                                       : null,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Flexible(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         '$decoratorName $decoratorLastName',
//                                         style: TextStyle(color: Colors.white, fontSize: 14),
//                                       ),
//                                       if (hasValidTitle)
//                                         Padding(
//                                           padding: EdgeInsets.only(top: 4),
//                                           child: Text(
//                                             title!,
//                                             style: TextStyle(
//                                               color: Colors.white.withOpacity(0.7),
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: IconButton(
//                                 padding: EdgeInsets.zero,
//                                 constraints: BoxConstraints(),
//                                 icon: Icon(
//                                   _isLiked ? Icons.favorite : Icons.favorite_border,
//                                   color: _isLiked ? Colors.red : Colors.white,
//                                   size: 20,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _isLiked = !_isLiked;
//                                   });
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: IconButton(
//                                 padding: EdgeInsets.zero,
//                                 constraints: BoxConstraints(),
//                                 icon: Icon(Icons.share, color: Colors.white, size: 20),
//                                 onPressed: () {
//                                   // Add share functionality here
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_videoController != null &&
//                 _videoController!.value.isInitialized &&
//                 isVideo &&
//                 _isLandscape)
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   color: Colors.black.withOpacity(0.5),
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   child: Column(
//                     children: [
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           return GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onPanDown: (details) {
//                               _seekToPosition(details.localPosition.dx, constraints.maxWidth);
//                             },
//                             onPanUpdate: (details) {
//                               _seekToPosition(details.localPosition.dx, constraints.maxWidth);
//                             },
//                             child: Container(
//                               height: 30,
//                               alignment: Alignment.center,
//                               child: VideoProgressIndicator(
//                                 _videoController!,
//                                 allowScrubbing: false,
//                                 padding: EdgeInsets.symmetric(horizontal: 16),
//                                 colors: VideoProgressColors(
//                                   playedColor: Colors.blue,
//                                   bufferedColor: Colors.grey[300]!,
//                                   backgroundColor: Colors.grey[600]!,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.replay_5, color: Colors.white, size: 30),
//                             onPressed: () {
//                               _videoController!.seekTo(
//                                 _videoController!.value.position - Duration(seconds: 5),
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                               color: Colors.white,
//                               size: 36,
//                             ),
//                             onPressed: () {
//                               if (mounted) {
//                                 setState(() {
//                                   _videoController!.value.isPlaying
//                                       ? _videoController!.pause()
//                                       : _videoController!.play();
//                                 });
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.forward_5, color: Colors.white, size: 30),
//                             onPressed: () {
//                               _videoController!.seekTo(
//                                 _videoController!.value.position + Duration(seconds: 5),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _seekToPosition(double dx, double width) {
//     if (_videoController != null && _videoController!.value.isInitialized) {
//       final relative = dx.clamp(0.0, width) / width;
//       final position = _videoController!.value.duration * relative;
//       _videoController!.seekTo(position);
//     }
//   }
// }