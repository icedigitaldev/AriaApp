import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isToday = _isToday(selectedDate);

    return Container(
      padding: ResponsiveSize.padding(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveSize.height(4)),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onDateChanged(
                selectedDate.subtract(const Duration(days: 1))
            ),
            icon: Icon(Icons.chevron_left, color: AppColors.primary),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateChanged(picked);
              }
            },
            child: Container(
              padding: ResponsiveSize.padding(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              decoration: BoxDecoration(
                gradient: AppGradients.totalAmountBackground,
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: ResponsiveSize.icon(18),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: ResponsiveSize.width(8)),
                  Text(
                    _formatDate(selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveSize.font(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: isToday ? null : () => onDateChanged(
                selectedDate.add(const Duration(days: 1))
            ),
            icon: Icon(
              Icons.chevron_right,
              color: isToday ? AppColors.iconMuted : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) {
      return 'Hoy';
    }
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}