import 'package:ecommerce_app/core/app_colors.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const AppNetworkImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.primaryLight,
          child: const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.textLight),
        ),
      ),
    );
  }
}