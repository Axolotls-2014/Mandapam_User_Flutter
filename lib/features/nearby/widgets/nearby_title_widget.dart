import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class NearbyTitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  const NearbyTitleWidget(
      {super.key, required this.title, this.onTap, this.image});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context)
                  ? 14.0
                  : 14.0,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          image != null
              ? Image.asset(image!, height: 20, width: 20)
              : const SizedBox(),
        ],
      ),
    ]);
  }
}
