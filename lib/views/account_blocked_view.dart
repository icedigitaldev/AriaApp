import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ice_storage/ice_storage.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../components/composite/transparent_app_bar.dart';
import '../router/app_router.dart';
import '../auth/current_user.dart';

class AccountBlockedView extends StatelessWidget {
  AccountBlockedView({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    await IceStorage.instance.auth.clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.phoneAuth,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    final userName = CurrentUserAuth.instance.name ?? 'Usuario';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: TransparentAppBar(backgroundColor: AppColors.appBarBackground),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: ResponsiveScaler.padding(
                    EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: ResponsiveScaler.height(40)),

                      // Icono grande limpio
                      Container(
                        width: ResponsiveScaler.width(130),
                        height: ResponsiveScaler.height(130),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: ResponsiveScaler.icon(56),
                          color: AppColors.error,
                        ),
                      ),

                      SizedBox(height: ResponsiveScaler.height(32)),

                      // Título con gradiente
                      Text(
                        'Cuenta Inhabilitada',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(28),
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = AppGradients.headerText.createShader(
                              Rect.fromLTWH(0.0, 0.0, 280.0, 70.0),
                            ),
                        ),
                      ),

                      SizedBox(height: ResponsiveScaler.height(8)),

                      // Subtítulo
                      Text(
                        'Hola, $userName',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(17),
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: ResponsiveScaler.height(40)),

                      // Card de aviso
                      Container(
                        width: double.infinity,
                        padding: ResponsiveScaler.padding(
                          EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(
                            ResponsiveScaler.radius(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: Offset(0, ResponsiveScaler.height(6)),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Icono grande centrado
                            Container(
                              width: ResponsiveScaler.width(56),
                              height: ResponsiveScaler.height(56),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: ResponsiveScaler.icon(28),
                                color: AppColors.warning,
                              ),
                            ),

                            SizedBox(height: ResponsiveScaler.height(20)),

                            Text(
                              'Tu cuenta ha sido desactivada temporalmente por el administrador del sistema.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(15),
                                color: AppColors.textMuted,
                                height: 1.6,
                              ),
                            ),

                            SizedBox(height: ResponsiveScaler.height(20)),

                            // Contacto
                            Container(
                              padding: ResponsiveScaler.padding(
                                EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveScaler.radius(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.support_agent_rounded,
                                    size: ResponsiveScaler.icon(18),
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: ResponsiveScaler.width(8)),
                                  Text(
                                    'Contacta al administrador',
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveScaler.font(13),
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón inferior
            Padding(
              padding: ResponsiveScaler.padding(
                EdgeInsets.fromLTRB(24, 20, 24, 24),
              ),
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(18),
                    ),
                  ),
                  elevation: 10,
                  shadowColor: AppColors.shadowPurple,
                ),
                child: Container(
                  height: ResponsiveScaler.height(60),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(18),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: AppColors.iconOnPrimary,
                          size: ResponsiveScaler.icon(22),
                        ),
                        SizedBox(width: ResponsiveScaler.width(10)),
                        Text(
                          'Cerrar sesión',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(17),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
