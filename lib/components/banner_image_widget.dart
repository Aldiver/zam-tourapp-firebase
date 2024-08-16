import 'package:flutter/material.dart';

class BannerImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const BannerImageWidget({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            double.infinity, // Makes the container span the width of the screen
        padding: const EdgeInsets.symmetric(
            horizontal: 4.0), // Padding around the image
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
          child: Image.asset(
            imageUrl,
            width: 64,
          ),
        ),
      ),
    );
  }
}
