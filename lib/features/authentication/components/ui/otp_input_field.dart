import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onBackspace;

  const OtpInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onTap,
    this.onBackspace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = focusNode.hasFocus;
    final hasValue = controller.text.isNotEmpty;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onBackspace?.call();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: ResponsiveScaler.width(48),
        height: ResponsiveScaler.height(60),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.backgroundAlternate.withOpacity(0.5)
              : hasValue
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
          border: Border.all(
            color: isActive
                ? AppColors.inputFocusedBorder
                : hasValue
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.inputBorder,
            width: 2,
          ),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            showCursor: false,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(24),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.0,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              isCollapsed: true,
            ),
            onChanged: onChanged,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
