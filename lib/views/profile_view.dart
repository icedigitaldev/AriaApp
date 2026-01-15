import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ui/status_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../auth/current_user.dart';
import '../features/attendance/components/ui/clock_in_button.dart';
import '../features/attendance/components/ui/hours_stat_card.dart';
import '../features/attendance/components/composite/profile_header_card.dart';
import '../features/attendance/components/composite/attendance_record_tile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Estado de ejemplo para el diseño
  bool _isClockedIn = false;
  String _currentCheckIn = '';

  void _toggleClockIn() {
    setState(() {
      if (_isClockedIn) {
        _isClockedIn = false;
        _currentCheckIn = '';
      } else {
        _isClockedIn = true;
        final now = TimeOfDay.now();
        _currentCheckIn =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    final user = CurrentUserAuth.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: StatusAppBar(backgroundColor: AppColors.appBarBackground),
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: ResponsiveScaler.padding(EdgeInsets.all(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del perfil
                ProfileHeaderCard(
                  name: user.name ?? 'Usuario',
                  role: user.role ?? 'staff',
                  department: user.department,
                  imageUrl: user.imageUrl ?? user.avatarUrl,
                ),
                SizedBox(height: ResponsiveScaler.height(28)),

                // Sección de Check-in
                _buildClockInSection(),
                SizedBox(height: ResponsiveScaler.height(28)),

                // Dashboard de horas
                _buildHoursSection(),
                SizedBox(height: ResponsiveScaler.height(28)),

                // Historial de registros
                _buildHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockInSection() {
    return Container(
      padding: ResponsiveScaler.padding(EdgeInsets.all(24)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, ResponsiveScaler.height(6)),
          ),
        ],
      ),
      child: Column(
        children: [
          // Estado actual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: ResponsiveScaler.width(10),
                height: ResponsiveScaler.width(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isClockedIn ? AppColors.success : AppColors.textMuted,
                ),
              ),
              SizedBox(width: ResponsiveScaler.width(8)),
              Text(
                _isClockedIn ? 'En turno' : 'Fuera de turno',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(16),
                  fontWeight: FontWeight.w600,
                  color: _isClockedIn ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (_isClockedIn && _currentCheckIn.isNotEmpty) ...[
            SizedBox(height: ResponsiveScaler.height(8)),
            Text(
              'Entrada: $_currentCheckIn',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(13),
                color: AppColors.textMuted,
              ),
            ),
          ],
          SizedBox(height: ResponsiveScaler.height(24)),
          // Botón principal
          ClockInButton(isClockedIn: _isClockedIn, onTap: _toggleClockIn),
          SizedBox(height: ResponsiveScaler.height(16)),
          Text(
            _isClockedIn
                ? 'Toca para registrar salida'
                : 'Toca para registrar entrada',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(13),
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Horas',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(18),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveScaler.height(14)),
        Row(
          children: [
            Expanded(
              child: HoursStatCard(
                label: 'Hoy',
                value: '6h 30m',
                icon: Icons.today,
                accentColor: AppColors.primary,
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(12)),
            Expanded(
              child: HoursStatCard(
                label: 'Esta Semana',
                value: '32h',
                icon: Icons.date_range,
                accentColor: AppColors.info,
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(12)),
            Expanded(
              child: HoursStatCard(
                label: 'Este Mes',
                value: '128h',
                icon: Icons.calendar_month,
                accentColor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimos Registros',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveScaler.height(10)),
        // Registros de ejemplo
        AttendanceRecordTile(
          date: 'Hoy, 15 Ene',
          checkIn: '08:30',
          checkOut: null,
          totalHours: '--',
        ),
        AttendanceRecordTile(
          date: 'Ayer, 14 Ene',
          checkIn: '08:15',
          checkOut: '17:45',
          totalHours: '9h 30m',
        ),
        AttendanceRecordTile(
          date: 'Lun, 13 Ene',
          checkIn: '08:00',
          checkOut: '16:30',
          totalHours: '8h 30m',
        ),
        AttendanceRecordTile(
          date: 'Dom, 12 Ene',
          checkIn: '09:00',
          checkOut: '15:00',
          totalHours: '6h 00m',
        ),
        AttendanceRecordTile(
          date: 'Sáb, 11 Ene',
          checkIn: '10:00',
          checkOut: '18:00',
          totalHours: '8h 00m',
        ),
      ],
    );
  }
}
