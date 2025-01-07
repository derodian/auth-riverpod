// lib/features/widgets/circular_profile_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CircularProfileImage extends StatelessWidget {
  const CircularProfileImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.radius = 20,
    this.onTap,
    this.isLoading = false,
    this.borderColor,
    this.borderWidth = 2,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  final String? imageUrl;
  final File? imageFile;
  final double radius;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? borderColor;
  final double borderWidth;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget(context);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? Colors.grey[300]!,
      highlightColor: shimmerHighlightColor ?? Colors.grey[100]!,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Theme.of(context).primaryColor,
            width: borderWidth,
          ),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(context),
      );
    }

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        placeholder: (context, url) => _buildLoadingAnimation(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: _buildPlaceholder(context),
    );
  }

  Widget _buildLoadingAnimation(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: Colors.grey[400],
      ),
    );
  }
}

// Example usage with different styles:
class ProfileImageStyles {
  static const defaultStyle = CircularProfileImage(
    radius: 50,
    borderWidth: 2,
  );

  static const largeStyle = CircularProfileImage(
    radius: 75,
    borderWidth: 3,
    borderColor: Colors.white,
  );

  static CircularProfileImage customStyle({
    required double radius,
    required Color borderColor,
    required Color shimmerBaseColor,
    required Color shimmerHighlightColor,
  }) {
    return CircularProfileImage(
      radius: radius,
      borderWidth: 2,
      borderColor: borderColor,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
    );
  }
}
