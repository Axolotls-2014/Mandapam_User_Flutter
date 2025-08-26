import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixam_mart/features/details/controllers/details_controller.dart';
import 'package:sixam_mart/features/media/view_decorator.dart';
import 'package:sixam_mart/features/nearby/controllers/decorator_controller.dart';
import 'package:sixam_mart/features/nearby/widgets/decorator_rating_bar.dart';
import 'package:sixam_mart/features/nearby/widgets/nearby_title_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/model/decorator_model.dart';

class NearbyDecoratorsList extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  final String searchQuery;

  const NearbyDecoratorsList({
    super.key,
    required this.isFood,
    required this.isShop,
    required this.searchQuery,
  });

  @override
  State<NearbyDecoratorsList> createState() => NearbyDecoratorsListState();
}

class NearbyDecoratorsListState extends State<NearbyDecoratorsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DecoratorController>().getNearByDecorator(true);
    });
  }

  Future<void> launchDialer(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $url";
    }
  }

  bool _matchesSearchQuery(User user) {
    if (widget.searchQuery.isEmpty) return true;
    final String fullName =
    '${user.fName ?? ''} ${user.lName ?? ''}'.toLowerCase();
    final String address = (user.address ?? '').toLowerCase();
    final String query = widget.searchQuery.toLowerCase();

    final List<String> events =
    (user.eventNames ?? []).map((e) => e.toString().toLowerCase()).toList();

    return fullName.contains(query) ||
        address.contains(query) ||
        events.any((event) => event.contains(query));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: GetBuilder<DecoratorController>(builder: (decoratorController) {
        if (decoratorController.decoratorModel == null) {
          return _buildShimmerEffect();
        }

        final matchingUsers = decoratorController.decoratorModel!.users!
            .where((user) => _matchesSearchQuery(user))
            .toList();

        if (matchingUsers.isEmpty) {
          return const SizedBox();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    0),
                child: NearbyTitleWidget(
                  title: 'Near By Decorators',
                  onTap: () {},
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                itemCount: matchingUsers.length,
                itemBuilder: (context, index) {
                  final user = matchingUsers[index];
                  String phoneNumber = user.phone ?? '';
                  String displayedPhone = phoneNumber.length > 13
                      ? phoneNumber.substring(0, 13)
                      : phoneNumber;

                  return Container(
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        Get.find<DetailsController>().clearMediaModel();
                        await Get.find<DetailsController>()
                            .getDetails(true, user.id!);
                        Get.to(ViewDecorator(
                          sharedPreferences: Get.find(),
                          decoratorId: user.id!.toString(),
                        ));
                      },
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                ),
                                child: user.imageFullUrl != null
                                    ? Image.network(
                                        user.imageFullUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.person,
                                                    size: 28,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                      )
                                    : Icon(Icons.person,
                                        size: 32,
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeDefault),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${user.fName} ${user.lName ?? ''}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      DecoratorRatingBar(
                                        rating:
                                            user.avgRating?.toDouble() ?? 0.0,
                                        ratingCount: user.ratingCount ?? 0,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  if (AuthHelper.isLoggedIn())
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            size: 16,
                                            color:
                                                Theme.of(context).primaryColor),
                                        const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall),
                                        GestureDetector(
                                          onTap: () =>
                                              launchDialer(user.phone!),
                                          child: Text(
                                            displayedPhone,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 12.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 14,
                                          color:
                                              Theme.of(context).disabledColor),
                                      const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Expanded(
                                        child: Text(
                                          user.address ?? '-',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 15,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Container(
                                height: 12,
                                width: 100,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


//Error fetching app version: