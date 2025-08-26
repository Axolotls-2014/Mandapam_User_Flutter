import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
//import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/media/view_media.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
//import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/home/widgets/category_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryView extends StatelessWidget {
  final String searchQuery;
  const CategoryView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        final filteredCategories = categoryController.categoryList
            ?.where((category) => category.title!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
            .toList();

        return (filteredCategories != null && filteredCategories.isEmpty)
            ? const SizedBox()
            : isPharmacy
            ? PharmacyCategoryView(categoryController: categoryController)
            : isFood
            ? FoodCategoryView(categoryController: categoryController)
            : Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: categoryController.categoryList != null
                      ? GridView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: filteredCategories!.length,
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall,
                        top: Dimensions.paddingSizeDefault),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      mainAxisSpacing:
                      Dimensions.paddingSizeSmall,
                      crossAxisSpacing:
                      Dimensions.paddingSizeSmall,
                    ),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: 120,
                        child: InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                            await SharedPreferences
                                .getInstance();
                            Get.to(() => ViewMediaScreen(
                              sharedPreferences: prefs,
                              selectedEventId:
                              filteredCategories[
                              index]
                                  .id
                                  .toString(),
                              fromScreen:
                              'CategoryScreen',
                            ));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(
                                      Dimensions
                                          .radiusSmall),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset:
                                      const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                      Dimensions
                                          .radiusSmall),
                                  child: CustomImage(
                                    image:
                                    '${filteredCategories[index].imageFullUrl}',
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions
                                      .paddingSizeExtraSmall),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: index == 0
                                        ? Dimensions
                                        .paddingSizeExtraSmall
                                        : 0,
                                    left: Dimensions
                                        .paddingSizeExtraSmall),
                                child: SizedBox(
                                  height: 30,
                                  child: Text(
                                    filteredCategories[index]
                                        .title!,
                                    style: robotoMedium
                                        .copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow
                                        .ellipsis,
                                    textAlign:
                                    TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : CategoryShimmer(
                      categoryController: categoryController),
                ),
                ResponsiveHelper.isMobile(context)
                    ? const SizedBox()
                    : categoryController.categoryList != null
                    ? Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (con) => Dialog(
                                child: SizedBox(
                                    height: 550,
                                    width: 600,
                                    child:
                                    CategoryPopUp(
                                      categoryController:
                                      categoryController,
                                    ))));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: Dimensions
                                .paddingSizeSmall),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor:
                          Theme.of(context)
                              .primaryColor,
                          child: Text('view_all'.tr,
                              style: TextStyle(
                                  fontSize: Dimensions
                                      .paddingSizeDefault,
                                  color: Theme.of(
                                      context)
                                      .cardColor)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                )
                    : CategoryShimmer(
                    categoryController: categoryController),
              ],
            ),
          ],
        );
      });
    });
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 160,
        child: categoryController.categoryList != null
            ? ListView.builder(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          itemCount: categoryController.categoryList!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeSmall,
                  top: Dimensions.paddingSizeDefault),
              child: InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  Get.to(() => ViewMediaScreen(
                    sharedPreferences: prefs,
                    selectedEventId: categoryController
                        .categoryList![index].id
                        .toString(),
                    fromScreen: 'CategoryScreen',
                  ));
                },
                borderRadius:
                BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Theme.of(context).cardColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100)),
                      child: CustomImage(
                        image:
                        '${categoryController.categoryList![index].imageFullUrl}',
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            categoryController.categoryList![index].title!,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ]),
                ),
              ),
            );
          },
        )
            : PharmacyCategoryShimmer(categoryController: categoryController),
      ),
    ]);
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 160,
          child: categoryController.categoryList != null
              ? ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                top: Dimensions.paddingSizeDefault),
            itemCount: categoryController.categoryList!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    top: Dimensions.paddingSizeDefault),
                child: InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    Get.to(() => ViewMediaScreen(
                      sharedPreferences: prefs,
                      selectedEventId: categoryController
                          .categoryList![index].id
                          .toString(),
                      fromScreen: 'CategoryScreen',
                    ));
                  },
                  borderRadius:
                  BorderRadius.circular(Dimensions.radiusSmall),
                  child: SizedBox(
                    width: 60,
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                            Radius.circular(100)),
                        child: CustomImage(
                          image:
                          '${categoryController.categoryList![index].imageFullUrl}',
                          height: 60,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              categoryController.categoryList![index].title ??
                                  '',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ]),
                  ),
                ),
              );
            },
          )
              : FoodCategoryShimmer(categoryController: categoryController),
        ),
      ]),
    ]);
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 3,
      padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeSmall,
          top: Dimensions.paddingSizeDefault),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Column(children: [
            Container(
                height: 70,
                width: 70,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                  right: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Colors.grey[300],
                )),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: EdgeInsets.only(
                  right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
              child: Container(
                height: 10,
                width: 50,
                color: Colors.grey[300],
              ),
            ),
          ]),
        );
      },
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
      const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: SizedBox(
            width: 60,
            child: Column(children: [
              ClipOval(
                child: Shimmer(
                  child: Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).shadowColor,
                      )),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: Shimmer(
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
      const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100)),
              ),
              child: Column(children: [
                Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100)),
                      color: Colors.grey[300],
                    )),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}