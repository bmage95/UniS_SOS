import 'package:flutter/material.dart';
import 'package:sos_unis/custom/custom_glass_bar.dart';

Widget buildBottomNavBar(BuildContext context, int currentIndex, ValueChanged<int> onTap) {
  return LiquidGlassBottomBar(
    //margin: EdgeInsets.zero, 
    height: 60,
    barBlurSigma: 5,
    activeBlurSigma: 20,
    currentIndex: currentIndex,
    onTap: onTap,
    activeColor: Colors.blueAccent,
    showLabels: false,
    items: [
      LiquidGlassBottomBarItem(
        imagePath: 'assets/icons/newspaper.svg',
        label: 'News'
      ),
      LiquidGlassBottomBarItem(
        imagePath: 'assets/icons/sos.svg',
        label: 'SOS',
        iconSize: 28.0,
      ),
      LiquidGlassBottomBarItem(
        imagePath: 'assets/icons/gear.svg',
        label: 'Settings'
      ),
    ],
  );
}