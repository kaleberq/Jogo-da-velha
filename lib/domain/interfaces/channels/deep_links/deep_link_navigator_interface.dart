import 'package:flutter/material.dart';

abstract class IDeepLinkNavigator {
  void navigate(NavigatorState navigator, Map<String, dynamic>? deepLink);
}
