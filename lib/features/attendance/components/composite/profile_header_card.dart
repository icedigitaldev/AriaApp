import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/ui/cached_network_image.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String role;
  final String? department;
  final String? imageUrl;

  const ProfileHeaderCard({
    Key? key,
    required this.name,
    required this.role,
    this.department,
    this.imageUrl,
  }) : super(key: key);

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'waiter':
        return 'Mesero';
      case 'kitchen':
        return 'Cocina';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  String _getDepartmentLabel(String? dept) {
    if (dept == null) return '';
    switch (dept.toLowerCase()) {
      case 'service':
        return 'Servicio';
      case 'production':
        return 'Producción';
      default:
        return dept;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(ResponsiveScaler.radius(20));

    return Container(
      padding: ResponsiveScaler.padding(EdgeInsets.all(20)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPurple,
            blurRadius: 20,
            offset: Offset(0, ResponsiveScaler.height(8)),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: ResponsiveScaler.width(72),
            height: ResponsiveScaler.width(72),
            decoration: BoxDecoration(
              gradient: imageUrl == null ? AppGradients.primaryButton : null,
              color: imageUrl != null ? AppColors.card : null,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(18)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowPurple,
                  blurRadius: 12,
                  offset: Offset(0, ResponsiveScaler.height(4)),
                ),
              ],
            ),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: ResponsiveScaler.width(72),
                    height: ResponsiveScaler.width(72),
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(18),
                    ),
                    placeholder: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(18),
                      ),
                      child: Image.asset(
                        'assets/images/aria-logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(18),
                    ),
                    child: Image.asset(
                      'assets/images/aria-logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          SizedBox(width: ResponsiveScaler.width(16)),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveScaler.height(4)),
                Row(
                  children: [
                    Container(
                      padding: ResponsiveScaler.padding(
                        EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveScaler.radius(8),
                        ),
                      ),
                      child: Text(
                        _getRoleLabel(role),
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (department != null) ...[
                      SizedBox(width: ResponsiveScaler.width(8)),
                      Text(
                        _getDepartmentLabel(department),
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(13),
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Ícono de configuración
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.iconMuted,
              size: ResponsiveScaler.icon(24),
            ),
          ),
        ],
      ),
    );
  }
}
