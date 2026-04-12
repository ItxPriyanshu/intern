import 'package:flutter/material.dart';

class ResponsiveUi {
  static double width(BuildContext context){
    return MediaQuery.of(context).size.width;
  }


  static double height(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double widhtPercent(BuildContext context, double percent){
    return width(context)*percent/100;
  }


  static double heightPercent(BuildContext context, double percent){
    return height(context)*percent/100;
  }

  static double font(BuildContext context, double size){
    double baseWidth = 375;
    return size*(width(context)/baseWidth);
  }
}