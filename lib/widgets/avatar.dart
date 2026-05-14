import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.imageUrl, this.size = 40});
  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fontSize = size / 2.6;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      alignment: Alignment.center,
      child: Text(
        Formatters.initials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (imageUrl == null || imageUrl!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.surfaceMuted, width: size, height: size),
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
