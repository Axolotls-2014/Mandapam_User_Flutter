import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/details/controllers/details_controller.dart';
import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:sixam_mart/features/details/screen/media/video/media_videos.dart';
import 'package:sixam_mart/features/store/widgets/store_details_screen_shimmer_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final dynamic decoratorId;
  const DetailsScreen({super.key, required this.decoratorId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
  int isSelected = 1;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 1,
      vsync: this,
      initialIndex: 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<DetailsController>().getDetails(true, widget.decoratorId);
      final events = Get.find<DetailsController>().events;
      if (events.isNotEmpty) {
        final oldController = tabController;
        tabController = TabController(
          length: events.length,
          vsync: this,
          initialIndex: events.length > 1 ? 1.clamp(0, events.length - 1) : 0,
        );
        tabController.addListener(() => setState(() {}));
        oldController.dispose();
      }
    });
  }

  Future<void> openGoogleMaps(String placeName) async {
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(placeName)}");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw "Could not open Google Maps.";
    }
  }

  Future<void> launchDialer(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget customTabButton({required String title, required int index}) {
    bool isActive = tabController.index == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          tabController.animateTo(index);
        },
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: isActive
                  ? Theme.of(context).primaryColor
                  : const Color.fromARGB(112, 255, 255, 255),
            ),
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.27,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 158, 158, 158),
        title: const Text(
          "Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Theme.of(context).cardColor),
            alignment: Alignment.center,
            child: const Icon(Icons.chevron_left, color: Colors.grey),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 231, 230, 230),
      body: GetBuilder<DetailsController>(
        builder: (detailsController) {
          if (detailsController.mediaModel == null) {
            return const StoreDetailsScreenShimmerWidget();
          }
          if (detailsController.events.isEmpty) {
            return const Center(child: Text("No events available"));
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.015,
                      horizontal: MediaQuery.of(context).size.width * 0.04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(176, 255, 255, 255),
                              spreadRadius: 0.01,
                              blurRadius:
                              MediaQuery.of(context).size.width * 0.02,
                              offset: const Offset(3, 7),
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(107, 33, 149, 243),
                              spreadRadius: 0.0,
                              blurRadius:
                              MediaQuery.of(context).size.width * 0.03,
                              offset: const Offset(1.6, 7),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(detailsController
                                .mediaModel!.userDetails!.imageFullUrl ??
                                "https://www.w3schools.com/w3images/avatar2.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.13,
                        height: MediaQuery.of(context).size.width * 0.13,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.76,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        detailsController
                                            .mediaModel!.userDetails!.name!,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  launchDialer(detailsController
                                      .mediaModel!.userDetails!.phone!);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(AuthHelper.isLoggedIn())
                                    const Icon(Icons.phone,
                                        color: Colors.grey, size: 14.0),
                                    SizedBox(
                                        width: MediaQuery.of(context).size.width *
                                            0.01),
                                    Text(
                                      detailsController
                                          .mediaModel!.userDetails!.phone!,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  openGoogleMaps(detailsController
                                      .mediaModel!.userDetails!.address!);
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: Colors.grey, size: 18.0),
                                    Expanded(
                                      child: Text(
                                        detailsController.mediaModel!.userDetails!
                                            .address!
                                            .split(',')[0],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: detailsController.events.isNotEmpty,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GetBuilder<DetailsController>(
                    builder: (detailsController) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: detailsController.events.length,
                        itemBuilder: (context, index) {
                          return customTabButton(
                            title: detailsController.events.keys
                                .elementAt(index),
                            index: index,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTapDown: (_) => detailsController.changeMedia(true),
                    child: AnimatedScale(
                      scale: detailsController.isPhoto ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: detailsController.isPhoto
                              ? const LinearGradient(colors: [
                            Color.fromARGB(255, 200, 60, 18),
                            Color.fromARGB(255, 255, 93, 44),
                          ])
                              : const LinearGradient(colors: [
                            Color.fromARGB(255, 200, 60, 18),
                            Color.fromARGB(255, 255, 93, 44),
                          ]),
                          borderRadius: BorderRadius.circular(10),
                          color: detailsController.isPhoto
                              ? null
                              : Colors.grey[300],
                        ),
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: const Text(
                          "Photos",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  GestureDetector(
                    onTapDown: (_) => detailsController.changeMedia(false),
                    child: AnimatedScale(
                      scale: !detailsController.isPhoto ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: !detailsController.isPhoto
                              ? const LinearGradient(colors: [
                            Color.fromARGB(255, 200, 60, 18),
                            Color.fromARGB(255, 255, 93, 44),
                          ])
                              : const LinearGradient(colors: [
                            Color.fromARGB(255, 200, 60, 18),
                            Color.fromARGB(255, 255, 93, 44),
                          ]),
                          borderRadius: BorderRadius.circular(10),
                          color: !detailsController.isPhoto
                              ? null
                              : Colors.grey[300],
                        ),
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: const Text(
                          "Videos",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                    controller: tabController,
                    children: detailsController.events.keys.map((eventTitle) {
                      int indexId = detailsController.events.keys
                          .toList()
                          .indexOf(eventTitle);
                      return buildTabContent(title: eventTitle, indexId: indexId);
                    }).toList()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTabContent({required String title, required int indexId}) {
    List<Map<String, List<Media>>> mediaObjuct = [];
    return GetBuilder<DetailsController>(builder: (detailsController) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.8,
                mainAxisSpacing: 2.8,
                childAspectRatio: 1,
              ),
              itemCount: detailsController.events[title]!.length,
              itemBuilder: (context, index) {
                Map<String, List<Media>> newMediaMap = {};
                for (int i = 0;
                i < detailsController.events[title]![index].media!.length;
                i++) {
                  if (!newMediaMap.containsKey(
                      "${detailsController.events[title]![index].media![i].mediaType}")) {
                    newMediaMap[
                    "${detailsController.events[title]![index].media![i].mediaType}"] = [];
                  }
                  newMediaMap[
                  "${detailsController.events[title]![index].media![i].mediaType}"]!
                      .add(detailsController.events[title]![index].media![i]);
                }

                mediaObjuct.add(newMediaMap);

                return (!detailsController.isPhoto)
                    ? VideoThumbnailWidget(
                  videoUrl: mediaObjuct[index]["video"]!,
                )
                    : Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showImageDialog(
                            context: context,
                            initialIndex: 0,
                            photos: mediaObjuct[index]["photo"]!);
                      },
                      child: Container(
                        color: Theme.of(context).dialogBackgroundColor,
                        width: double.infinity,
                        height: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                              mediaObjuct[index]["photo"]![0]
                                  .imageFullUrl!,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    if (mediaObjuct[index]["photo"]!.length > 1)
                      Positioned(
                        top: 10,
                        right: 8,
                        child: Icon(
                          Icons.collections,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      )
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  void _showImageDialog({
    required BuildContext context,
    required int initialIndex,
    required List<Media> photos,
  }) {
    PageController pageController = PageController(initialPage: initialIndex);
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (photos.length != 1)
                            const Expanded(child: SizedBox()),
                          Flexible(
                            child: SizedBox(
                              child: PageView.builder(
                                itemCount: photos.length,
                                controller: pageController,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        photos[index].imageFullUrl!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (photos.length != 1)
                            SmoothPageIndicator(
                              controller: pageController,
                              count: photos.length,
                              effect: const WormEffect(
                                dotHeight: 10,
                                dotWidth: 10,
                                activeDotColor: Colors.white,
                                dotColor: Colors.grey,
                              ),
                            ),
                          if (photos.length != 1)
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
