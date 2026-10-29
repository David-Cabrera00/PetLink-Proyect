import 'package:flutter/material.dart';

Widget buildLocalPhotoPreview(
  String path, {
  required BoxFit fit,
  required double width,
  required double height,
  required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
}) {
  return Image.network(
    path,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}
