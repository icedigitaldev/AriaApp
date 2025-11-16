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

  const OtpInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = focusNode.hasFocus;
    final hasValue = controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: ResponsiveSize.width(52),
      height: ResponsiveSize.height(64),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.backgroundAlternate.withOpacity(0.5)
            : hasValue
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
        border: Border.all(
          color: isActive
              ? AppColors.inputFocusedBorder
              : hasValue
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.inputBorder,
          width: 2.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveSize.font(24),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}