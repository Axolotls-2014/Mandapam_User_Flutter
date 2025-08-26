import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/media/functions.dart';
import 'package:sixam_mart/features/media/view_decorator_model.dart';
import 'package:sixam_mart/features/media/wishlist_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class ViewDecorator extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final dynamic decoratorId;
  final bool fromMedia;

  const ViewDecorator({
    required this.sharedPreferences,
    required this.decoratorId,
    this.fromMedia = false});

  @override
  State<ViewDecorator> createState() => _ViewDecoratorState();
}

class _ViewDecoratorState extends State<ViewDecorator> {
  late ApiService apiService;
  List<Map<String, dynamic>>? events;
  Map<String, dynamic>? selectedEvent;
  bool isDropdownOpen = false;
  List<int> eventIds = [];
  List<String> eventNames = [];
  bool isLoading = true;
  String? selectedEventName;
  int? selectedEventIndex;
  Map<int, List<dynamic>> eventMediaMap = {};
  List<dynamic> filteredMediaList = [];
  bool isFetchingMedia = false;
  int? selectedMediaIndex;
  late AuthController authController;
  int _selectedTabIndex = 0;
  Map<String, dynamic>? decoratorProfile;
  double _photoScale = 1.0;
  double _videoScale = 1.0;
  List<WishlistMedia> wishlistItems2 = [];
  List<WishlistMedia> displayedMedia2 = [];
  List<int> wishlistMediaIds = [];
  String? errorMessage;
  List<int> eventsWithMedia = [];
  bool hasFetchedUserDetails = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(sharedPreferences: widget.sharedPreferences, apiClient: Get.find<ApiClient>());
    fetchEventList();
    fetchWishlistMedia();
    selectedEventIndex = 0;
  }

  void fetchEventList() async {
    events = await apiService.fetchEvents();
    if (events != null && events!.isNotEmpty) {
      eventIds = events!.map((event) => event['id'] as int).toList();
      eventNames = events!.map((event) => event['title'] as String).toList();

      // Check each event for media
      String userId = widget.decoratorId;
      for (int i = 0; i < eventIds.length; i++) {
        final response = await apiService.getMediaByUserAndEvent(
          userId: userId,
          eventId: eventIds[i],
        );

        // Always extract user details if available, regardless of media
        if (response != null && response['user_details'] != null && decoratorProfile == null) {
          setState(() {
            decoratorProfile = response['user_details'];
            hasFetchedUserDetails = true;
          });
        }

        if (response != null && response['data'] != null && response['data'].isNotEmpty) {
          bool hasMedia = false;
          for (var batch in response['data']) {
            if (batch['media'] != null && batch['media'].isNotEmpty) {
              hasMedia = true;
              break;
            }
          }
          if (hasMedia) {
            eventsWithMedia.add(eventIds[i]);
          }
        }
      }

      // Filter events to only those with media
      events = events!.where((event) => eventsWithMedia.contains(event['id'])).toList();
      eventIds = events!.map((event) => event['id'] as int).toList();
      eventNames = events!.map((event) => event['title'] as String).toList();

      if (eventIds.isNotEmpty) {
        selectedEventIndex = 0;
        fetchMediaByUserAndEvent(userId, eventIds[selectedEventIndex!]);
      } else {
        // If no events with media, still try to get user details from any API call
        if (!hasFetchedUserDetails && widget.decoratorId != null) {
          try {
            final response = await apiService.getMediaByUserAndEvent(
              userId: widget.decoratorId,
              eventId: eventIds.isNotEmpty ? eventIds[0] : 0,
            );

            if (response != null && response['user_details'] != null) {
              setState(() {
                decoratorProfile = response['user_details'];
                hasFetchedUserDetails = true;
              });
            }
          } catch (e) {
            print("Error fetching user details: $e");
          }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchWishlistMedia() async {
    try {
      int userId = int.tryParse(widget.decoratorId.toString()) ?? 0;
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
      });

      print('Fetched_Media_IDs:');
      for (var id in mediaIds) {
        print(id);
      }

    } catch (e) {
      print('Error_fetching_wishlist: $e');
      setState(() {
        wishlistItems2 = [];
        displayedMedia2 = [];
        wishlistMediaIds = [];
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchMediaByUserAndEvent(userId, int eventId) async {
    // Always extract user details if available, even if we have cached media
    if (!hasFetchedUserDetails) {
      final response = await apiService.getMediaByUserAndEvent(
        userId: userId,
        eventId: eventId,
      );

      if (response != null && response['user_details'] != null) {
        setState(() {
          decoratorProfile = response['user_details'];
          hasFetchedUserDetails = true;
        });
      }
    }

    if (eventMediaMap.containsKey(eventId)) {
      setState(() {
        filteredMediaList = _filterMedia(eventMediaMap[eventId]!, _selectedTabIndex);
        isFetchingMedia = false;
      });
      return;
    }

    setState(() {
      isFetchingMedia = true;
    });

    final response = await apiService.getMediaByUserAndEvent(
      userId: userId,
      eventId: eventId,
    );

    if (response != null) {
      // Always update user details if available
      if (response['user_details'] != null) {
        setState(() {
          decoratorProfile = response['user_details'];
          hasFetchedUserDetails = true;
        });
      }

      List<dynamic> allMedia = [];
      for (var batch in response['data']) {
        for (var mediaItem in batch['media']) {
          mediaItem['title'] = mediaItem['title'] ?? '';
          if (mediaItem['file_path'] != null && mediaItem['file_path'].isNotEmpty ||
              mediaItem['image_full_url'] != null && mediaItem['image_full_url'].isNotEmpty) {
            allMedia.add(mediaItem);
          }
        }
      }
      eventMediaMap[eventId] = allMedia;

      setState(() {
        filteredMediaList = _filterMedia(allMedia, _selectedTabIndex);
        isFetchingMedia = false;
      });
    } else {
      eventMediaMap[eventId] = [];
      setState(() {
        filteredMediaList = [];
        isFetchingMedia = false;
      });
    }
  }

  List<dynamic> _filterMedia(List<dynamic> media, int tabIndex) {
    return media.where((media) {
      if (tabIndex == 0) {
        return media['media_type'] == 'photo' &&
            (media['image_full_url'] != null && media['image_full_url'].isNotEmpty);
      } else {
        return media['media_type'] == 'video' &&
            (media['image_full_url'] != null && media['image_full_url'].isNotEmpty);
      }
    }).toList();
  }

  void _filterMediaByType(int index) {
    setState(() {
      _selectedTabIndex = index;
      if (selectedEventIndex != null) {
        int currentEventId = eventIds[selectedEventIndex!];
        filteredMediaList = _filterMedia(eventMediaMap[currentEventId] ?? [], index);
      }
    });
  }

  void _showMediaFullScreen(int index) {
    final currentWishlistIds = List<int>.from(wishlistMediaIds);

    print('Passing to FullScreenMediaViewer:');
    print('Media ID: ${filteredMediaList[index]['media_id']}');
    print('Wishlist IDs: $currentWishlistIds');

    final mediaItem = filteredMediaList[index];
    final mediaId = int.tryParse(mediaItem['media_id'].toString()) ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaList: [MediaItem(
            mediaId: mediaId,
            mediaType: mediaItem['media_type'],
            filePath: mediaItem['file_path'],
            imageFullUrl: mediaItem['image_full_url'],
            title: mediaItem['title'],
            description: mediaItem['description'],
          )],
          initialIndex: 0,
          sharedPreferences: widget.sharedPreferences,
          decoratorProfile: decoratorProfile,
          wishlistMediaIds: currentWishlistIds,
        ),
      ),
    ).then((_) {
      // Refresh data when returning
      fetchWishlistMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppBar(title: 'Details', backButton: widget.fromMedia ? false : true),
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
      ) : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // ALWAYS SHOW USER DETAILS - DON'T HIDE AT ALL
            if (decoratorProfile != null) Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: decoratorProfile!['image_full_url'] != null
                        ? ClipOval(
                      child: Image.network(
                        decoratorProfile!['image_full_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            decoratorProfile!['name'].isNotEmpty
                                ? decoratorProfile!['name'][0].toUpperCase()
                                : 'D',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                        : Center(
                      child: Text(
                        decoratorProfile!['name'].isNotEmpty
                            ? decoratorProfile!['name'][0].toUpperCase()
                            : 'D',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${decoratorProfile!['name']} ${decoratorProfile!['l_name'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final lat = decoratorProfile!['latitude'];
                                final lng = decoratorProfile!['longitude'];
                                if (lat != null && lng != null) {
                                  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  }
                                }
                              },
                              child: Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                decoratorProfile!['address'] ?? 'Address not available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final phone = decoratorProfile!['phone']?.replaceAll('+91', '');
                                if (phone != null && phone.isNotEmpty) {
                                  final url = 'tel:$phone';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  }
                                }
                              },
                              child: Icon(
                                Icons.phone,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              decoratorProfile!['phone'] ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (decoratorProfile!['about_us'] != null && (decoratorProfile!['about_us'] as String).trim().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              decoratorProfile!['about_us'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (eventNames.isNotEmpty) Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEventIndex = index;
                        _selectedTabIndex = 0;
                      });
                      if (widget.decoratorId != null) {
                        try {
                          String userId = widget.decoratorId;
                          fetchMediaByUserAndEvent(userId, eventIds[selectedEventIndex!]);
                        } catch (e) {
                          print("Error: Could not convert decoratorId to int");
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedEventIndex == index ? Color(0xFF0D6EFD) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          eventNames[index],
                          style: TextStyle(
                              color: selectedEventIndex == index ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 4),
            Container(
              margin: EdgeInsets.only(top: 8, bottom: 8),
              height: 48,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() => _photoScale = 0.9);
                      },
                      onTapUp: (_) {
                        setState(() => _photoScale = 1.0);
                        _filterMediaByType(0);
                      },
                      onTapCancel: () {
                        setState(() => _photoScale = 1.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 100),
                            scale: _photoScale,
                            child: Icon(
                              Icons.photo,
                              color: _selectedTabIndex == 0 ? Colors.black : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() => _videoScale = 0.9);
                      },
                      onTapUp: (_) {
                        setState(() => _videoScale = 1.0);
                        _filterMediaByType(1);
                      },
                      onTapCancel: () {
                        setState(() => _videoScale = 1.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 100),
                            scale: _videoScale,
                            child: Icon(
                              Icons.videocam,
                              color: _selectedTabIndex == 1 ? Colors.black : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            isFetchingMedia
                ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(color: Colors.white);
              },
            ) : filteredMediaList.isEmpty
                ? Container(
              height: 350,
              child: Center(
                child: Text(
                  'No media available',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: filteredMediaList.length,
              itemBuilder: (context, index) {
                final media = filteredMediaList[index];
                return GestureDetector(
                  onTap: () {
                    _showMediaFullScreen(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: media['media_type'] == 'photo'
                        ? Image.network(media['image_full_url'], fit: BoxFit.cover)
                        : VideoPreviewWidget(videoUrl: media['image_full_url']),
                  ),
                );
              },
            ),
          ],
        ),
      )
          : NotLoggedInScreen(callBack: (value) {
        setState(() {});
        fetchEventList();
      }),
    );
  }
}

class VideoPreviewWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
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
          color: Colors.black,
          child: _isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
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
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Icon(
            Icons.videocam,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class FullScreenMediaViewer extends StatefulWidget {
  final List<MediaItem> mediaList;
  final int initialIndex;
  final SharedPreferences sharedPreferences;
  final Map<String, dynamic>? decoratorProfile;
  final List<int> wishlistMediaIds;

  const FullScreenMediaViewer({
    required this.mediaList,
    required this.initialIndex,
    required this.sharedPreferences,
    this.decoratorProfile,
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

    // Debug prints
    print('FullScreenMediaViewer initialized with:');
    print('Media ID: ${widget.mediaList[currentIndex].mediaId}');
    print('Wishlist IDs: ${widget.wishlistMediaIds}');
    print('Is media in wishlist: ${widget.wishlistMediaIds.contains(widget.mediaList[currentIndex].mediaId)}');

    _isLiked = widget.wishlistMediaIds.contains(widget.mediaList[currentIndex].mediaId);

    _initializeVideoController();
    _apiService = ApiService(
      sharedPreferences: widget.sharedPreferences,
      apiClient: Get.find<ApiClient>(),
    );
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
    if (widget.mediaList[currentIndex].mediaType == 'video') {
      _videoController = VideoPlayerController.network(widget.mediaList[currentIndex].imageFullUrl)
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

    final prefs = widget.sharedPreferences;
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not authenticated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessingLike = true;
    });

    try {
      final media = widget.mediaList[currentIndex];
      final mediaId = media.mediaId;
      if (mediaId == null) return;

      dynamic response;
      if (_isLiked) {
        response = await _apiService.removeFromWishlist(itemId: mediaId);
      } else {
        response = await _apiService.addToWishlist(
          itemId: mediaId,
          userId: userId,
        );
      }

      if (mounted) {
        if (response == null || response.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLiked
                  ? 'Failed to remove from wishlist'
                  : 'Failed to add to wishlist'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _isLiked = !_isLiked;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingLike = false;
        });
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
    final String? title = media.title;
    final bool hasValidTitle = title != null && title.trim().isNotEmpty;
    final bool isVideo = media.mediaType == 'video';
    final String? description = media.description;
    final bool hasValidDescription = description != null && description.trim().isNotEmpty;
    final decoratorName = widget.decoratorProfile?['name'] ?? '';
    final decoratorLastName = widget.decoratorProfile?['l_name'] ?? '';
    final decoratorImage = widget.decoratorProfile?['image_full_url'];

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
              }
              Navigator.of(context).pop(true);
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
                    _isLiked = widget.wishlistMediaIds.contains(widget.mediaList[index].mediaId);
                  });
                }
              },
              itemBuilder: (context, index) {
                final media = widget.mediaList[index];
                if (media.mediaType == 'photo') {
                  return Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: PhotoView(
                        imageProvider: NetworkImage(media.imageFullUrl),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.5,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        backgroundDecoration: BoxDecoration(color: Colors.black),
                      ),
                    ),
                  );
                } else if (media.mediaType == 'video') {
                  return _videoController != null && _videoController!.value.isInitialized
                      ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                      : Container(
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
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
                              Navigator.pop(context);
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
                                  )
                                      : null,
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$decoratorName $decoratorLastName',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      if (hasValidDescription)
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            description!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      if (hasValidTitle)
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            title!,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
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
                            // IconButton(
                            //   padding: EdgeInsets.zero,
                            //   constraints: BoxConstraints(),
                            //   icon: AnimatedSwitcher(
                            //     duration: Duration(milliseconds: 300),
                            //     transitionBuilder: (Widget child, Animation<double> animation) {
                            //       return ScaleTransition(scale: animation, child: child);
                            //     },
                            //     child: Icon(
                            //       _isLiked ? Icons.favorite : Icons.favorite_border,
                            //       key: ValueKey<bool>(_isLiked),
                            //       color: _isLiked ? Colors.red : Colors.white,
                            //       size: 20,
                            //     ),
                            //   ),
                            //   onPressed: _toggleWishlist,
                            // ),

                              SizedBox.shrink(),
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