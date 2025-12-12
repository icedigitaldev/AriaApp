import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onTap;

  const PhoneInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta del campo
          Padding(
            padding: ResponsiveScaler.padding(const EdgeInsets.fromLTRB(24, 24, 24, 12)),
            child: Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: ResponsiveScaler.icon(20),
                  color: AppColors.icon,
                ),
                SizedBox(width: ResponsiveScaler.width(8)),
                Text(
                  'Número de teléfono',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Campo de entrada
          Container(
            margin: ResponsiveScaler.margin(const EdgeInsets.fromLTRB(24, 0, 24, 24)),
            decoration: BoxDecoration(
              color: focusNode.hasFocus
                  ? AppColors.backgroundAlternate.withOpacity(0.5)
                  : AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
              border: Border.all(
                color: focusNode.hasFocus
                    ? AppColors.inputFocusedBorder.withOpacity(0.5)
                    : AppColors.inputBorder,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Prefijo del país
                Padding(
                  padding: ResponsiveScaler.padding(const EdgeInsets.symmetric(horizontal: 20)),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/flag-peru.png',
                        width: ResponsiveScaler.width(30),
                      ),
                      SizedBox(width: ResponsiveScaler.width(10)),
                      Text(
                        '+51',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(17),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Separador
                Container(
                  width: 1,
                  height: ResponsiveScaler.height(35),
                  color: AppColors.inputBorder,
                ),
                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                      _PhoneNumberFormatter(),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(18),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '999 999 999',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textHint,
                        fontSize: ResponsiveScaler.font(18),
                        letterSpacing: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: ResponsiveScaler.padding(const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      )),
                    ),
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Formateador personalizado para números telefónicos
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');

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