import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/ui/app_loader.dart';
import '../components/ui/app_snackbar.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/authentication/components/composite/auth_header.dart';
import '../features/authentication/controllers/auth_controller.dart';
import '../router/app_router.dart';

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
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  void _clearInputs() {
    for (var controller in _controllers) {
      controller.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
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

  String _getEnteredPin() {
    return _controllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[0];
      _controllers[index].selection = TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    setState(() {});
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _verifyPin(AuthController authController) async {
    final pin = _getEnteredPin();

    if (pin.length != 6) {
      AppSnackbar.error(context, 'Ingresa los 6 dígitos del PIN');
      return;
    }

    final success = await authController.submitPin(pin);

    if (!mounted) return;

    if (success) {
      AppRouter.navigateToHome(context);
    } else {
      _shakeController.forward().then((_) => _shakeController.reverse());
      _clearInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final staffName = args?['staffName'] ?? '';
    final phoneNumber = args?['phoneNumber'] ?? '';

    return Consumer(
      builder: (context, ref) {
        final authState = ref.watch(authControllerProvider);
        final authController = ref.notifier(authControllerProvider);

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildTopBar(authController),
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
                              SizedBox(height: ResponsiveScaler.height(40)),
                              AuthHeader(
                                icon: Icons.lock_rounded,
                                title: staffName.isNotEmpty
                                    ? '¡Hola, $staffName!'
                                    : 'Verificación',
                                subtitle:
                                    'Ingresa tu PIN de acceso\nde 6 dígitos',
                                phoneNumber: phoneNumber,
                              ),
                              SizedBox(height: ResponsiveScaler.height(60)),
                              _buildPinInputs(),
                              if (authState.errorMessage != null) ...[
                                SizedBox(height: ResponsiveScaler.height(20)),
                                _buildErrorMessage(authState.errorMessage!),
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
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(12)),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: ResponsiveScaler.icon(20),
          ),
          SizedBox(width: ResponsiveScaler.width(8)),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(13),
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(AuthController authController) {
    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.only(left: 16, top: 8),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
            onTap: () {
              authController.goBack();
              Navigator.pop(context);
            },
            child: Container(
              padding: ResponsiveScaler.padding(const EdgeInsets.all(12)),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 15,
                    offset: Offset(0, ResponsiveScaler.height(5)),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: ResponsiveScaler.icon(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInputs() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            padding: ResponsiveScaler.padding(
              const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 25,
                  offset: Offset(0, ResponsiveScaler.height(10)),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildSingleInput(index)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleInput(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: ResponsiveScaler.width(44),
      height: ResponsiveScaler.height(56),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyPressed(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          showCursor: false,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(22),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.symmetric(
              vertical: ResponsiveScaler.height(14),
            ),
            filled: true,
            fillColor: hasValue
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
              borderSide: BorderSide(
                color: hasValue
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.inputBorder,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
              borderSide: BorderSide(
                color: AppColors.inputFocusedBorder,
                width: 2.5,
              ),
            ),
          ),
          onChanged: (value) => _onDigitChanged(index, value),
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isLoading, AuthController authController) {
    return Padding(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.fromLTRB(24, 30, 24, 24),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _verifyPin(authController),
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
                        Icons.check_circle_rounded,
                        color: AppColors.iconOnPrimary,
                        size: ResponsiveScaler.icon(24),
                      ),
                      SizedBox(width: ResponsiveScaler.width(10)),
                      Text(
                        'Ingresar',
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
    );
  }
}
