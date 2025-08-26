import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/features/details/domain/model/view_media_model.dart';
import 'package:sixam_mart/features/media/functions.dart';
import 'package:sixam_mart/features/media/view_decorator.dart';
import 'package:sixam_mart/features/media/wishlist_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class ViewMediaScreen extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final bool fromDashboard;
  final String selectedEventId;
  final String? fromScreen;

  ViewMediaScreen({
    required this.sharedPreferences,
    required this.selectedEventId,
    this.fromDashboard = false,
    this.fromScreen,
  });

  @override
  _ViewMediaScreenState createState() => _ViewMediaScreenState();
}

class _ViewMediaScreenState extends State<ViewMediaScreen> {
  late ApiService apiService;
  List<Map<String, dynamic>>? events;
  Map<String, dynamic>? selectedEvent;
  bool isDropdownOpen = false;
  List<int> eventIds = [];
  List<String> eventNames = [];
  bool isLoading = true;
  String? selectedEventName;
  int? selectedEventIndex;
  List<MediaItem> mediaList = [];
  List<MediaItem> filteredMediaList = [];
  bool isFetchingMedia = false;
  int? selectedMediaIndex;
  late AuthController authController;
  String? globalUserId;
  TextEditingController searchController = TextEditingController();
  List<dynamic> decoratorsData = [];
  Map<int, Map<String, dynamic>> decoratorInfoMap = {};
  List<WishlistMedia> wishlistItems = [];
  List<WishlistMedia> displayedItems = [];
  String? errorMessage;
  RefreshController _refreshController = RefreshController();

  List<WishlistMedia> wishlistItems2 = [];
  List<WishlistMedia> displayedMedia2 = [];
  List<int> wishlistMediaIds = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService(sharedPreferences: widget.sharedPreferences, apiClient: Get.find<ApiClient>());
    _fetchUserId().then((_) {
      if (globalUserId != null) {
        try {
          int userId = int.parse(globalUserId!);
          if (widget.fromScreen == 'CategoryScreen') {
            fetchWishlistMedia(userId);
            fetchMediaByUserAndEvent(userId, int.parse(widget.selectedEventId));
          } else {
            fetchWishlistByUser(userId);
          }
        } catch (e) {
          print("Error: Could not convert globalUserId to int");
        }
      }
    });
    selectedEventIndex = 0;
    searchController.addListener(_filterMedia);
  }

  Future<void> _onRefresh() async {
    if (globalUserId != null) {
      try {
        int userId = int.parse(globalUserId!);
        if (widget.fromScreen == 'CategoryScreen') {
          await fetchWishlistMedia(userId);
          await fetchMediaByUserAndEvent(userId, int.parse(widget.selectedEventId));
        } else {
          await fetchWishlistByUser(userId);
        }
      } catch (e) {
        print("Error during refresh: $e");
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  void _filterMedia() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        if (widget.fromScreen == 'CategoryScreen') {
          filteredMediaList = List.from(mediaList);
        } else {
          displayedItems = List.from(wishlistItems);
        }
      } else {
        if (widget.fromScreen == 'CategoryScreen') {
          filteredMediaList = mediaList.where((media) {
            final title = media.title?.toLowerCase() ?? '';
            return title.contains(query);
          }).toList();
        } else {
          displayedItems = wishlistItems.where((item) {
            final title = item.title.toLowerCase();
            return title.contains(query);
          }).toList();
        }
      }
    });
  }

  Future<void> _fetchUserId() async {
    authController = Get.find<AuthController>();
    globalUserId = await authController.getUserId();

    if (globalUserId != null) {
      print("Stored_User_ID: $globalUserId");
    } else {
      print("Error: Could not fetch User ID");
    }
  }

  Future<void> fetchWishlistMedia(int userId) async {
    try {
      final response = await apiService.getWishlist(userId: userId);

      List<int> mediaIds = response.wishlist
          .where((item) => item.mediaId != null)
          .map((item) => item.mediaId!)
          .toList();

      List<WishlistMedia> items = response.wishlist
          .map((item) => WishlistMedia.fromWishlistItem(item))
          .toList();

      setState(() {
        wishlistItems2 = items;
        displayedMedia2 = List.from(items);
        wishlistMediaIds = mediaIds;
        isLoading = false;
      });

      print('Fetched_Media_IDs:');
      for (var id in mediaIds) {
        print(id);
      }

    } catch (e) {
      print('Error fetching wishlist: $e');
      setState(() {
        wishlistItems2 = [];
        displayedMedia2 = [];
        wishlistMediaIds = [];
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchWishlistByUser(int userId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Fetching wishlist for user ID: $userId');
      final response = await apiService.getWishlist(userId: userId);
      print('Raw API response: $response');

      List<WishlistMedia> items = response.wishlist.map((item) => WishlistMedia.fromWishlistItem(item)).toList().reversed.toList();
      print('Parsed wishlist items: $items');

      setState(() {
        wishlistItems = items;
        displayedItems = List.from(items);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching wishlist: $e');
      setState(() {
        wishlistItems = [];
        displayedItems = [];
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchMediaByUserAndEvent(int userId, int eventId) async {
    setState(() {
      isFetchingMedia = true;
      isLoading = true;
    });

    final response = await apiService.getNearbyDecoratorsMedia(
      userId: userId,
      eventId: eventId,
    );

    if (response != null && response['data'] is List && response['data'].isNotEmpty) {
      decoratorsData = response['data'];
      decoratorInfoMap.clear();

      List<MediaItem> allMedia = [];
      for (var batch in response['data']) {
        final decoratorId = batch['decorator_id'];
        decoratorInfoMap[decoratorId] = {
          'name': batch['decorator_name'],
          'last_name': batch['decorator_last_name'],
          'image_full_url': batch['image_full_url'],
        };

        for (var mediaItem in batch['media']) {
          try {
            if (mediaItem['image_full_url'] != null && mediaItem['image_full_url'].toString().isNotEmpty) {
              mediaItem['decorator_id'] = decoratorId;
              allMedia.add(MediaItem.fromJson(mediaItem));
            }
          } catch (e) {
            print("Error parsing media item: $e");
          }
        }
      }

      setState(() {
        mediaList = allMedia;
        filteredMediaList = List.from(mediaList);
        isFetchingMedia = false;
        isLoading = false;
      });
    } else {
      setState(() {
        mediaList = [];
        filteredMediaList = [];
        isFetchingMedia = false;
        isLoading = false;
      });
    }
  }

  void _showMediaFullScreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaList: widget.fromScreen == 'CategoryScreen' ? filteredMediaList : displayedItems,
          initialIndex: index,
          sharedPreferences: widget.sharedPreferences,
          decoratorInfoMap: decoratorInfoMap,
          fromWishlist: widget.fromScreen != 'CategoryScreen',
          wishlistMediaIds: wishlistMediaIds,
        ),
      ),
    ).then((value) {
      if (value == true && globalUserId != null) {
        try {
          int userId = int.parse(globalUserId!);
          if (widget.fromScreen == 'CategoryScreen') {
            fetchMediaByUserAndEvent(userId, int.parse(widget.selectedEventId));
          } else {
            fetchWishlistByUser(userId);
          }
        } catch (e) {
          print("Error: Could not convert globalUserId to int");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.fromScreen == 'CategoryScreen' ? 'View Media' : 'Favorite';
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(pageIndex: 0)),
              (route) => false,
        );
        return false;
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade100,
        appBar: CustomAppBar(
          title: appBarTitle,
          backButton: widget.fromDashboard ? false : true,
          onBackPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen(pageIndex: 0)),
                  (route) => false,
            );
          },
        ),
        body: AuthHelper.isLoggedIn()
            ? isLoading
            ? Container(
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          ),
        ) : RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search media...',
                      hintStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                isFetchingMedia
                    ? GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(color: Colors.white);
                  },
                )
                    : widget.fromScreen == 'CategoryScreen'
                    ? filteredMediaList.isEmpty
                    ? Container(
                  height: 350,
                  child: Center(
                    child: Text(
                      searchController.text.isEmpty
                          ? 'No media available'
                          : 'No media found for "${searchController.text}"',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: filteredMediaList.length,
                  itemBuilder: (context, index) {
                    final media = filteredMediaList[index];
                    return GestureDetector(
                      onTap: () {
                        _showMediaFullScreen(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white),
                        child: media.mediaType == 'photo'
                            ? media.imageFullUrl != null
                            ? Image.network(
                            media.imageFullUrl!,
                            fit: BoxFit.cover)
                            : Placeholder()
                            : media.imageFullUrl != null
                            ? VideoPreviewWidget(
                            videoUrl:
                            media.imageFullUrl!)
                            : Placeholder(),
                      ),
                    );
                  },
                )
                    : displayedItems.isEmpty
                    ? Container(
                  height: 350,
                  child: Center(
                    child: Text(
                      searchController.text.isEmpty
                          ? 'No favorites available'
                          : 'No favorites found for "${searchController.text}"',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final media = displayedItems[index];
                    return GestureDetector(
                      onTap: () {
                        _showMediaFullScreen(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white),
                        child: media.mediaType == 'photo'
                            ? media.imageUrl != null
                            ? Image.network(
                            media.imageUrl!,
                            fit: BoxFit.cover)
                            : Placeholder()
                            : media.imageUrl != null
                            ? VideoPreviewWidget(
                            videoUrl: media.imageUrl!)
                            : Placeholder(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
            :  NotLoggedInScreen(callBack: (value) {
          setState(() {});
        }),
      ),




    );
  }
}

class VideoPreviewWidget extends StatefulWidget {
  final String videoUrl;

  VideoPreviewWidget({required this.videoUrl});

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: _controller.value.isInitialized
              ? ClipRRect(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          )
              : Container(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Icon(
            Icons.videocam,
            color: Colors.black.withOpacity(0.6),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class FullScreenMediaViewer extends StatefulWidget {
  final List<dynamic> mediaList;
  final int initialIndex;
  final SharedPreferences sharedPreferences;
  final Map<int, Map<String, dynamic>> decoratorInfoMap;
  final bool fromWishlist;
  final List<int> wishlistMediaIds;

  const FullScreenMediaViewer({
    required this.mediaList,
    required this.initialIndex,
    required this.sharedPreferences,
    required this.decoratorInfoMap,
    this.fromWishlist = false,
    required this.wishlistMediaIds,
  });

  @override
  _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> with WidgetsBindingObserver {
  late PageController _pageController;
  late int currentIndex;
  VideoPlayerController? _videoController;
  bool _isLandscape = false;
  bool _isTitleExpanded = false;
  bool _isLiked = false;
  bool _isProcessingLike = false;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _initializeVideoController();
    _apiService = ApiService(
      sharedPreferences: widget.sharedPreferences,
      apiClient: Get.find<ApiClient>(),
    );
    _isLiked = widget.fromWishlist;
    if (!widget.fromWishlist && widget.mediaList.isNotEmpty) {
      final media = widget.mediaList[currentIndex];
      _isLiked = widget.wishlistMediaIds.contains(_getMediaId(media));
    }
  }

  int? _getMediaId(dynamic media) {
    if (media is MediaItem) {
      return media.mediaId;
    } else if (media is WishlistMedia) {
      return media.mediaId;
    }
    return null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final orientation = WidgetsBinding.instance.window.physicalSize.aspectRatio;
    setState(() {
      _isLandscape = orientation > 1.0;
    });
    super.didChangeMetrics();
  }

  Future<void> _toggleOrientation() async {
    if (_isLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLandscape) {
      await _toggleOrientation();
      return false;
    }
    return true;
  }

  void _initializeVideoController() {
    final media = widget.mediaList[currentIndex];
    final mediaType = widget.fromWishlist ? media.mediaType : media.mediaType;
    final mediaUrl = widget.fromWishlist ? media.imageUrl : media.imageFullUrl;

    if (mediaType == 'video' && mediaUrl != null) {
      _videoController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
          }
        });
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isProcessingLike || !mounted) return;
    setState(() {
      _isLiked = !_isLiked;
    });

    final authController = Get.find<AuthController>();
    final userIdString = await authController.getUserId();
    if (userIdString == null) {
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }
    final userId = int.tryParse(userIdString);
    if (userId == null) return;

    try {
      final media = widget.mediaList[currentIndex];
      final mediaId = _getMediaId(media);
      if (mediaId == null) return;

      dynamic response;
      if (!_isLiked) {
        response = await _apiService.removeFromWishlist(itemId: mediaId);
      } else {
        response = await _apiService.addToWishlist(
          itemId: mediaId,
          userId: userId,
        );
      }

      if (mounted && (response == null || response.containsKey('error'))) {
        setState(() {
          _isLiked = !_isLiked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked
                ? 'Failed to remove from wishlist'
                : 'Failed to add to wishlist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _seekToPosition(double dx, double width) {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final relative = dx.clamp(0.0, width) / width;
      final position = _videoController!.value.duration * relative;
      _videoController!.seekTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.mediaList[currentIndex];
    final String? title = widget.fromWishlist ? media.title : (media.title?.trim().isNotEmpty == true ? media.title : 'Media');
    final bool isVideo = widget.fromWishlist ? media.mediaType == 'video' : media.mediaType == 'video';
    final bool hasValidTitle = title != null && title.trim().isNotEmpty;

    final decoratorId = widget.fromWishlist ? media.decoratorId : media.decoratorId ?? 0;
    final decoratorInfo = widget.decoratorInfoMap[decoratorId] ?? {};
    final decoratorName = widget.fromWishlist ? media.decoratorName : decoratorInfo['name'] ?? '';
    final decoratorLastName = widget.fromWishlist ? '' : decoratorInfo['last_name'] ?? '';
    final decoratorImage = widget.fromWishlist ? media.decoratorImage : decoratorInfo['image_full_url'];

    final String? rawDescription = widget.fromWishlist ? media.description : media.description;
    final bool hasValidDescription = rawDescription != null && rawDescription.trim().isNotEmpty;
    final String description = hasValidDescription ? rawDescription.trim() : '';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (_isLandscape) {
                await _toggleOrientation();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (isVideo)
              IconButton(
                icon: Icon(
                  _isLandscape ? Icons.screen_lock_portrait : Icons.screen_lock_landscape,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleOrientation,
              ),
          ],
        ),
        body: Stack(
          children: [
            PageView.builder(
              itemCount: widget.mediaList.length,
              controller: _pageController,
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    currentIndex = index;
                    _videoController?.dispose();
                    _videoController = null;
                    _initializeVideoController();
                    _isTitleExpanded = false;
                    _isLiked = widget.fromWishlist ? true : widget.wishlistMediaIds.contains(_getMediaId(widget.mediaList[index]));
                  });
                }
              },
              itemBuilder: (context, index) {
                final media = widget.mediaList[index];
                final mediaType = widget.fromWishlist ? media.mediaType : media.mediaType;
                final mediaUrl = widget.fromWishlist ? media.imageUrl : media.imageFullUrl;
                if (mediaType == 'photo' && mediaUrl != null) {
                  return Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: PhotoView(
                        imageProvider: NetworkImage(mediaUrl),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.5,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        backgroundDecoration: BoxDecoration(color: Colors.black),
                      ),
                    ),
                  );
                } else if (mediaType == 'video' && mediaUrl != null) {
                  double _scale = 1.0;
                  Matrix4 _matrix = Matrix4.identity();

                  return Center(
                    child: _videoController != null && _videoController!.value.isInitialized
                        ? Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: _isLandscape
                                ? MediaQuery.of(context).size.height * 0.7
                                : MediaQuery.of(context).size.height * 0.5,
                            child: GestureDetector(
                              onTap: _toggleOrientation,
                              onScaleStart: (ScaleStartDetails details) {},
                              onScaleUpdate: (ScaleUpdateDetails details) {
                                if (mounted) {
                                  setState(() {
                                    _scale = details.scale.clamp(1.0, 3.0);
                                    _matrix = Matrix4.identity()
                                      ..scale(_scale, _scale, 1.0);
                                  });
                                }
                              },
                              onDoubleTap: () {
                                if (mounted) {
                                  setState(() {
                                    _scale = 1.0;
                                    _matrix = Matrix4.identity();
                                  });
                                }
                              },
                              child: ClipRect(
                                child: Transform(
                                  transform: _matrix,
                                  alignment: Alignment.center,
                                  child: AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!_isLandscape)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onPanDown: (details) {
                                          _seekToPosition(details.localPosition.dx, constraints.maxWidth);
                                        },
                                        onPanUpdate: (details) {
                                          _seekToPosition(details.localPosition.dx, constraints.maxWidth);
                                        },
                                        child: Container(
                                          height: 30,
                                          alignment: Alignment.center,
                                          child: VideoProgressIndicator(
                                            _videoController!,
                                            allowScrubbing: false,
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            colors: VideoProgressColors(
                                              playedColor: Colors.blue,
                                              bufferedColor: Colors.grey[300]!,
                                              backgroundColor: Colors.grey[600]!,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.replay_5, color: Colors.white, size: 30),
                                        onPressed: () {
                                          _videoController!.seekTo(
                                            _videoController!.value.position - Duration(seconds: 5),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _videoController!.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                        onPressed: () {
                                          if (mounted) {
                                            setState(() {
                                              _videoController!.value.isPlaying
                                                  ? _videoController!.pause() : _videoController!.play();
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.forward_5, color: Colors.white, size: 30),
                                        onPressed: () {
                                          _videoController!.seekTo(
                                            _videoController!.value.position + Duration(seconds: 5),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                        : Container(
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            Positioned(
              bottom: isVideo ? (_isLandscape ? 20 : 100) : 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDecorator(
                                    sharedPreferences: widget.sharedPreferences,
                                    decoratorId: decoratorId.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white,
                                  backgroundImage: decoratorImage != null
                                      ? NetworkImage(decoratorImage)
                                      : null,
                                  child: decoratorImage == null && decoratorName.isNotEmpty
                                      ? Text(
                                    decoratorName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ) : null,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.fromWishlist ? decoratorName : '$decoratorName $decoratorLastName',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      if (hasValidDescription)
                                        Text(
                                          description,
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      if (hasValidTitle)
                                        Text(
                                          title,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isProcessingLike)
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: _isProcessingLike
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ) : AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: AuthHelper.isLoggedIn()
                                      ? Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_border,
                                    key: ValueKey<bool>(_isLiked),
                                    color: _isLiked ? Colors.red : Colors.white,
                                    size: 20,
                                  )
                                      : SizedBox.shrink(),
                                ),
                                onPressed: () {
                                  final authController = Get.find<AuthController>();
                                  authController.getUserId().then((userId) {
                                    if (userId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Please login to add to wishlist')),
                                      );
                                      return;
                                    }
                                    _toggleWishlist();
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_videoController != null &&
                _videoController!.value.isInitialized &&
                isVideo &&
                _isLandscape)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanDown: (details) {
                              _seekToPosition(details.localPosition.dx, constraints.maxWidth);
                            },
                            onPanUpdate: (details) {
                              _seekToPosition(details.localPosition.dx, constraints.maxWidth);
                            },
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              child: VideoProgressIndicator(
                                _videoController!,
                                allowScrubbing: false,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                colors: VideoProgressColors(
                                  playedColor: Colors.blue,
                                  bufferedColor: Colors.grey[300]!,
                                  backgroundColor: Colors.grey[600]!,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_5, color: Colors.white, size: 30),
                            onPressed: () {
                              _videoController!.seekTo(
                                _videoController!.value.position - Duration(seconds: 5),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _videoController!.value.isPlaying
                                      ? _videoController!.pause()
                                      : _videoController!.play();
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.forward_5, color: Colors.white, size: 30),
                            onPressed: () {
                              _videoController!.seekTo(
                                _videoController!.value.position + Duration(seconds: 5),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}

class RefreshController {
  void refreshCompleted() {}
}
