import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/authentication/components/ui/phone_input_field.dart';
import '../features/authentication/controllers/auth_controller.dart';
import '../router/app_router.dart';

class PhoneAuthView extends StatefulWidget {
  const PhoneAuthView({Key? key}) : super(key: key);

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView>
    with SingleTickerProviderStateMixin {
  // TickerProviderStateMixin para animaciones
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool isKeyboardVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Inicializar video
    _videoController = VideoPlayerController.asset('assets/media/aria.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
        setState(() {}); // Actualizar para mostrar el video
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitPhone(AuthController authController) async {
    FocusScope.of(context).unfocus();

    final staffData = await authController.submitPhoneAndGetStaff(
      _phoneController.text,
    );

    if (staffData != null && mounted) {
      Navigator.pushNamed(
        context,
        AppRouter.otpVerification,
        arguments: {
          'staffName': staffData['name'] ?? '',
          'phoneNumber': '+51 ${_phoneController.text}',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Consumer(
      builder: (context, ref) {
        final authState = ref.watch(authControllerProvider);
        final authController = ref.notifier(authControllerProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: ResponsiveScaler.padding(
                          const EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: ResponsiveScaler.height(60)),

                            // Video Container estilo "Sidebar"
                            Center(
                              child: Container(
                                width: ResponsiveScaler.width(120),
                                height: ResponsiveScaler.height(120),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveScaler.radius(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowPurple.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 30,
                                      offset: Offset(
                                        0,
                                        ResponsiveScaler.height(15),
                                      ),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    3,
                                  ), // Anillo exterior (ring-2)
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(
                                      0.2,
                                    ), // Color del anillo (purple-200 approx)
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveScaler.radius(30),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      2,
                                    ), // Offset (ring-offset-1)
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveScaler.radius(27),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveScaler.radius(25),
                                      ),
                                      child:
                                          _videoController.value.isInitialized
                                          ? FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: _videoController
                                                    .value
                                                    .size
                                                    .width,
                                                height: _videoController
                                                    .value
                                                    .size
                                                    .height,
                                                child: VideoPlayer(
                                                  _videoController,
                                                ),
                                              ),
                                            )
                                          : Container(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveScaler.height(32)),

                            // Título
                            Text(
                              'Bienvenido',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(32),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = AppGradients.headerText
                                      .createShader(
                                        const Rect.fromLTWH(
                                          0.0,
                                          0.0,
                                          300.0,
                                          70.0,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: ResponsiveScaler.height(12)),

                            // Subtítulo
                            Text(
                              'Ingresa tu número de teléfono\npara continuar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(17),
                                color: AppColors.textSecondary,
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                            ),

                            SizedBox(height: ResponsiveScaler.height(80)),

                            PhoneInputField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              onTap: () => setState(() {}),
                            ),
                            if (authState.errorMessage != null) ...[
                              SizedBox(height: ResponsiveScaler.height(16)),
                              Container(
                                padding: ResponsiveScaler.padding(
                                  const EdgeInsets.all(12),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveScaler.radius(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: ResponsiveScaler.icon(20),
                                    ),
                                    SizedBox(width: ResponsiveScaler.width(8)),
                                    Expanded(
                                      child: Text(
                                        authState.errorMessage!,
                                        style: GoogleFonts.poppins(
                                          fontSize: ResponsiveScaler.font(13),
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomSection(authState.isLoading, authController),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(bool isLoading, AuthController authController) {
    return Padding(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.fromLTRB(24, 30, 24, 24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSendButton(isLoading, authController),
          if (!isKeyboardVisible) ...[
            SizedBox(height: ResponsiveScaler.height(20)),
            _buildTermsText(),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton(bool isLoading, AuthController authController) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleSubmitPhone(authController),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(18)),
        ),
        elevation: 10,
        shadowColor: AppColors.shadowPurple,
      ),
      child: Container(
        height: ResponsiveScaler.height(60),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(18)),
        ),
        child: Center(
          child: isLoading
              ? AppLoader(size: ResponsiveScaler.width(28))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      color: AppColors.iconOnPrimary,
                      size: ResponsiveScaler.icon(22),
                    ),
                    SizedBox(width: ResponsiveScaler.width(10)),
                    Text(
                      'Continuar',
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
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(13),
            color: AppColors.textMuted,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Al continuar, aceptas nuestros '),
            TextSpan(
              text: 'Términos de Servicio',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' y '),
            TextSpan(
              text: 'Política de Privacidad',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
