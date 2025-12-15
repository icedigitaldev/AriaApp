import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class RestaurantHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onHistoryTap;
  final String? avatarUrl;

  const RestaurantHeader({
    Key? key,
    this.onProfileTap,
    this.onHistoryTap,
    this.avatarUrl,
  }) : super(key: key);

  // Obtiene imagen desde caché o la descarga
  Future<Uint8List?> _getCachedImage(String url) async {
    final isCached = await IceStorage.instance.images.isImageCached(url);
    if (isCached) {
      return await IceStorage.instance.images.getCachedImage(url);
    }
    return await IceStorage.instance.images.downloadAndCacheImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final borderRadius = BorderRadius.circular(ResponsiveScaler.radius(16));

    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        children: [
          // Logo / Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: ResponsiveScaler.width(48),
              height: ResponsiveScaler.height(48),
              decoration: BoxDecoration(
                gradient: !hasAvatar ? AppGradients.primaryButton : null,
                color: hasAvatar ? AppColors.card : null,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowPurple,
                    blurRadius: 12,
                    offset: Offset(0, ResponsiveScaler.height(4)),
                  ),
                ],
              ),
              child: hasAvatar
                  ? FutureBuilder<Uint8List?>(
                      future: _getCachedImage(avatarUrl!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError || snapshot.data == null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveScaler.radius(12),
                            ),
                            child: Image.asset(
                              'assets/images/aria-logo.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: borderRadius,
                          child: Image.memory(
                            snapshot.data!,
                            width: ResponsiveScaler.width(48),
                            height: ResponsiveScaler.height(48),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(12),
                      ),
                      child: Image.asset(
                        'assets/images/aria-logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          SizedBox(width: ResponsiveScaler.width(16)),
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARIA Meseros',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(24),
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppGradients.headerText.createShader(
                        const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                  ),
                ),
                Text(
                  'Mesa de control',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // History Button
          if (onHistoryTap != null)
            IconButton(
              onPressed: onHistoryTap,
              icon: Container(
                padding: ResponsiveScaler.padding(const EdgeInsets.all(8)),
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(
                    ResponsiveScaler.radius(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, ResponsiveScaler.height(4)),
                    ),
                  ],
                ),
                child: Icon(Icons.history, color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
