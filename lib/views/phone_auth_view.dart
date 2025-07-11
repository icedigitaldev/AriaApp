import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../utils/logger.dart';

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
    isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          _buildHeader(),
                          const SizedBox(height: 80),
                          _buildPhoneInputSection(),
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

  Widget _buildHeader() {
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
              Icons.phone_android_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Bienvenido',
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
          'Ingresa tu número de teléfono\npara continuar',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 17,
            color: Colors.grey[700],
            height: 1.5,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Número de teléfono',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: _phoneFocusNode.hasFocus
                  ? const Color(0xFFF3E5F5).withOpacity(0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _phoneFocusNode.hasFocus
                    ? const Color(0xFF9C27B0).withOpacity(0.5)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '🇵🇪',
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '+51',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 35,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                      _PhoneNumberFormatter(),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: '999 999 999',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSendButton(),
          if (!isKeyboardVisible) ...[
            const SizedBox(height: 20),
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
        AppLogger.log('Enviando SMS al: +51 ${_phoneController.text}', prefix: 'AUTH:');

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
                Icons.message_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Enviar código SMS',
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
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Al continuar, aceptas nuestros '),
            TextSpan(
              text: 'Términos de Servicio',
              style: TextStyle(
                color: const Color(0xFF9C27B0),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: '\ny '),
            TextSpan(
              text: 'Política de Privacidad',
              style: TextStyle(
                color: const Color(0xFF9C27B0),
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length <= 3) {
      return newValue;
    } else if (text.length <= 6) {
      final formatted = '${text.substring(0, 3)} ${text.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      final formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}