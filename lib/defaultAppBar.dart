import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultAppBar extends AppBar {
  DefaultAppBar({Key? key, PreferredSizeWidget? bottom})
      : super(
            key: key,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/NP_H_W.svg'),
                SvgPicture.asset('assets/SPA_H_W.svg'),
              ],
            ),
            bottom: bottom);
}
