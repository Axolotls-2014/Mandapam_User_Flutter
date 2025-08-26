import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/util/dimensions.dart';

class DecoratorCardShimmer extends StatelessWidget {
  const DecoratorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              // borderRadius: const BorderRadius.vertical(
              //   top: Radius.circular(Dimensions.radiusSmall),
              // ),
              shape: BoxShape.circle,
              color: Theme.of(context).shadowColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: 15,
                        width: 200,
                        color: Theme.of(context).shadowColor),
                    const SizedBox(height: 5),
                    Container(
                        height: 10,
                        width: 130,
                        color: Theme.of(context).shadowColor),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star,
                            color: Theme.of(context).shadowColor, size: 15);
                      }),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
