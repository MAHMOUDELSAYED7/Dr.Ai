import 'package:dr_ai/core/constant/image.dart';
import 'package:dr_ai/core/helper/extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SocialLoginCard extends StatelessWidget {
  const SocialLoginCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: context.outlinedButtonTheme.style,
          child: _buildSVGIcon(ImageManager.googleIcon),
          onPressed: () {},
        ),
        OutlinedButton(
          style: context.outlinedButtonTheme.style,
          child: _buildSVGIcon(ImageManager.facebookIcon),
          onPressed: () {},
        ),
        OutlinedButton(
          style: context.outlinedButtonTheme.style,
          child: _buildSVGIcon(ImageManager.appleIcon),
          onPressed: () {},
        ),
      ],
    );
  }

  SvgPicture _buildSVGIcon(String icon) {
    return SvgPicture.asset(
      icon,
      width: 24.w,
      height: 24.w,
    );
  }
}
