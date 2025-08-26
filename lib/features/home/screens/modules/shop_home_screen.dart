import 'package:flutter/material.dart';
import 'package:sixam_mart/features/nearby/screens/nearby_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';

class ShopHomeScreen extends StatelessWidget {
  final String searchQuery;
  const ShopHomeScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    debugPrint("isLoggedIn: $isLoggedIn");

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   decoration: const BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage(Images.shopModuleBannerBg),
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      //   child: const Column(
      //     children: [
      // BadWeatherWidget(),
      //       BannerView(isFeatured: false),
      //       SizedBox(height: 12),
      //     ],
      //   ),
      // ),

      CategoryView(searchQuery: searchQuery),
      // isLoggedIn ? const VisitAgainView() : const SizedBox(),
      // const MostPopularItemView(isFood: false, isShop: true),
      NearbyDecoratorsList(isFood: false, isShop: true, searchQuery: searchQuery),
      // SizedBox(height: 80),
      // const FlashSaleViewWidget(),
      // const MiddleSectionBannerView(),
      // const HighlightWidget(),
      // const PopularStoreView(),
      // const BrandsViewWidget(),
      // const SpecialOfferView(isFood: false, isShop: true),
      // const ProductWithCategoriesView(fromShop: true),
      // const JustForYouView(),
      // const FeaturedCategoriesView(),
      // // const StoreWiseBannerView(),
      // const ItemThatYouLoveView(forShop: true,),
      // const NewOnMartView(isShop: true,isPharmacy: false),
      // const PromotionalBannerView(),
    ]);
  }
}