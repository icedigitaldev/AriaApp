import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../utils/logger.dart';

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

  void _shakeError() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
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
    AppLogger.log('Reenviando código OTP', prefix: 'AUTH:');
    setState(() {
      resendTimer = 30;
      canResend = false;
    });
    _startResendTimer();

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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final phoneNumber = args?['phoneNumber'] ?? '+51 999 999 999';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(
        backgroundColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFFCE4EC),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          _buildHeader(phoneNumber),
                          const SizedBox(height: 60),
                          _buildOtpInputs(),
                          const SizedBox(height: 20),
                          _buildResendSection(),
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
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String phoneNumber) {
    return Column(
      children: [
        Hero(
          tag: 'auth-icon',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFFE91E63),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Verificación',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF7B1FA2),
                  Color(0xFFE91E63),
                ],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ingresa el código de 6 dígitos\nenviado a',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 17,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            phoneNumber,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9C27B0),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputs() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpField(index)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpField(int index) {
    final isActive = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 52,
      height: 64,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF3E5F5).withOpacity(0.5)
            : hasValue
            ? const Color(0xFF9C27B0).withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF9C27B0)
              : hasValue
              ? const Color(0xFF9C27B0).withOpacity(0.5)
              : Colors.grey[300]!,
          width: 2.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF9C27B0),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Si hay valor, seleccionar todo el texto para reemplazo fácil
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: value.length,
            );

            // Mover al siguiente campo si no es el último
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Si borra, ir al campo anterior
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onTap: () {
          // Seleccionar todo el texto cuando se hace tap
          if (_controllers[index].text.isNotEmpty) {
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          '¿No recibiste el código?',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !canResend
              ? Container(
            key: const ValueKey('timer'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Reenviar en $resendTimer segundos',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : TextButton(
            key: const ValueKey('resend'),
            onPressed: _resendCode,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF9C27B0),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reenviar código',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: ElevatedButton(
        onPressed: isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 10,
          shadowColor: Colors.purple.withOpacity(0.4),
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9C27B0),
                Color(0xFFE91E63),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Verificar código',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
    final code = _controllers.map((c) => c.text).join();
    AppLogger.log('Verificando código: $code', prefix: 'AUTH:');

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isLoading = false);

      // TODO: Ajustar navegación según el rol del usuario
      // Por ahora navega directamente a kitchen-orders
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/kitchen-orders',
            (route) => false,
      );
    }
  }
}