import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design/app_colors.dart';

class LogoView extends StatelessWidget {
  final double width;
  final double height;

  const LogoView({super.key, this.width = 50.0, this.height = 50.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 20.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
              'assets/logo.svg',
            width: width,
            height: height,
            color: AppColors.brandColor,
          ),
        ],
      ),
    );
  }
}
