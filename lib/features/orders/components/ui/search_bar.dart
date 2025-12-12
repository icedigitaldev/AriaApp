import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchBar({
    Key? key,
    required this.onChanged,
    this.hintText = 'Buscar...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(horizontal: 20)
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(15)),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: ResponsiveScaler.font(14),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textHint,
            fontSize: ResponsiveScaler.font(14),
          ),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.iconMuted),
        ),
      ),
    );
  }
}