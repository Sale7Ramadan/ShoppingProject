import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xff2C2C2C);

const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [Colors.black, Colors.red],
  stops: [0.1, 1.0],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const LinearGradient kBackgroundGradientAppbar = LinearGradient(
  colors: [Color(0xff7B0001), Colors.black],
  stops: [0.1, 1.0],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const kImageLogo = 'Assets/Images/K_Shoes.png';

const kID = 'id';

String filterStatus = 'Pending';
