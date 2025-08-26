import 'package:flutter/material.dart';
import 'package:sixam_mart/features/nearby/widgets/decorator_card_shimmer.dart';

class NearbyShimmer extends StatefulWidget {
  const NearbyShimmer({super.key});

  @override
  State<NearbyShimmer> createState() => _NearbyShimmerState();
}

class _NearbyShimmerState extends State<NearbyShimmer> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 80, crossAxisCount: 1),
      physics: const BouncingScrollPhysics(),

      shrinkWrap: true,
      itemCount: 5,
      // padding: widget.padding,
      itemBuilder: (context, index) {
        return const DecoratorCardShimmer();
      },
    );
  }
}
