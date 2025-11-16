import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/authentication/components/ui/otp_input_field.dart';
import '../features/authentication/components/composite/auth_header.dart';
import '../features/authentication/components/composite/resend_code_section.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  bool isLoading = false;
  int resendTimer = 30;
  bool canResend = false;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendTimer();

    // Focus en el primer campo al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _animationController.forward();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  void _resendCode() {
    setState(() {
      resendTimer = 30;
      canResend = false;
    });
    _startResendTimer();

    // Limpiar todos los campos
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final phoneNumber = args?['phoneNumber'] ?? '+51 999 999 999';

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: ResponsiveSize.padding(const EdgeInsets.symmetric(horizontal: 24.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: ResponsiveSize.height(40)),
                        // Header modular
                        AuthHeader(
                          icon: Icons.lock_rounded,
                          title: 'Verificación',
                          subtitle: 'Ingresa el código de 6 dígitos\nenviado a',
                          phoneNumber: phoneNumber,
                        ),
                        SizedBox(height: ResponsiveSize.height(60)),
                        _buildOtpInputs(),
                        SizedBox(height: ResponsiveSize.height(20)),
                        // Sección de reenvío modular
                        ResendCodeSection(
                          resendTimer: resendTimer,
                          canResend: canResend,
                          onResend: _resendCode,
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

  Widget _buildTopBar() {
    return Container(
      padding: ResponsiveSize.padding(const EdgeInsets.only(left: 16, top: 8)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: ResponsiveSize.padding(const EdgeInsets.all(12)),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 15,
                    offset: Offset(0, ResponsiveSize.height(5)),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: ResponsiveSize.icon(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputs() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            padding: ResponsiveSize.padding(const EdgeInsets.symmetric(vertical: 32, horizontal: 16)),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 25,
                  offset: Offset(0, ResponsiveSize.height(10)),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => OtpInputField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) {
                    // Manejo de navegación entre campos
                    if (value.isNotEmpty) {
                      _controllers[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: value.length,
                      );
                      if (index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    setState(() {});
                  },
                  onTap: () {
                    // Seleccionar todo el texto al tocar
                    if (_controllers[index].text.isNotEmpty) {
                      _controllers[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controllers[index].text.length,
                      );
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: ResponsiveSize.padding(const EdgeInsets.fromLTRB(24, 30, 24, 24)),
      child: ElevatedButton(
        onPressed: isLoading ? null : _verifyOtp,
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
                  Icons.check_circle_rounded,
                  color: AppColors.iconOnPrimary,
                  size: ResponsiveSize.icon(24),
                ),
                SizedBox(width: ResponsiveSize.width(10)),
                Text(
                  'Verificar código',
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
      ),
    );
  }

  Future<void> _verifyOtp() async {
    setState(() => isLoading = true);

    // Simulación de verificación
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }
  }
}