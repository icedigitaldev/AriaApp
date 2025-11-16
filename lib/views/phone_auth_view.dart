import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/authentication/components/ui/phone_input_field.dart';
import '../features/authentication/components/composite/auth_header.dart';

class PhoneAuthView extends StatefulWidget {
  const PhoneAuthView({Key? key}) : super(key: key);

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool isLoading = false;
  bool isKeyboardVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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
                    padding: ResponsiveSize.padding(const EdgeInsets.symmetric(horizontal: 24.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: ResponsiveSize.height(60)),
                        // Header reutilizable
                        const AuthHeader(
                          icon: Icons.phone_android_rounded,
                          title: 'Bienvenido',
                          subtitle: 'Ingresa tu número de teléfono\npara continuar',
                        ),
                        SizedBox(height: ResponsiveSize.height(80)),
                        // Campo de entrada modular
                        PhoneInputField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          onTap: () => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: ResponsiveSize.padding(const EdgeInsets.fromLTRB(24, 30, 24, 24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSendButton(),
          if (!isKeyboardVisible) ...[
            SizedBox(height: ResponsiveSize.height(20)),
            _buildTermsText(),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : () async {
        setState(() => isLoading = true);

        // Simular proceso de envío
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushNamed(
            context,
            '/otp-verification',
            arguments: {
              'phoneNumber': '+51 ${_phoneController.text}',
            },
          );
          setState(() => isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(18)),
        ),
        elevation: 10,
        shadowColor: AppColors.shadowPurple,
      ),
      child: Container(
        height: ResponsiveSize.height(60),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(18)),
        ),
        child: Center(
          child: isLoading
              ? AppLoader(
            size: ResponsiveSize.width(28),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message_rounded,
                color: AppColors.iconOnPrimary,
                size: ResponsiveSize.icon(22),
              ),
              SizedBox(width: ResponsiveSize.width(10)),
              Text(
                'Enviar código SMS',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSize.font(17),
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
      padding: ResponsiveSize.padding(const EdgeInsets.symmetric(horizontal: 24)),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(13),
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