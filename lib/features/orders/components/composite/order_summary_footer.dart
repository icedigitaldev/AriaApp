import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../components/ui/app_loader.dart';

class OrderSummaryFooter extends StatefulWidget {
  final double totalAmount;
  final bool isLoading;
  final VoidCallback onConfirm;
  final Function(String responsibleName, bool isSpecialEvent) onValuesChanged;

  const OrderSummaryFooter({
    Key? key,
    required this.totalAmount,
    required this.isLoading,
    required this.onConfirm,
    required this.onValuesChanged,
  }) : super(key: key);

  @override
  State<OrderSummaryFooter> createState() => _OrderSummaryFooterState();
}

class _OrderSummaryFooterState extends State<OrderSummaryFooter> {
  bool _isSpecialEvent = false;
  final _responsibleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _responsibleController.addListener(_notifyValuesChanged);
  }

  @override
  void dispose() {
    _responsibleController.removeListener(_notifyValuesChanged);
    _responsibleController.dispose();
    super.dispose();
  }

  void _notifyValuesChanged() {
    widget.onValuesChanged(_responsibleController.text.trim(), _isSpecialEvent);
  }

  void _toggleSpecialEvent() {
    setState(() => _isSpecialEvent = !_isSpecialEvent);
    _notifyValuesChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: ResponsiveScaler.width(20),
        right: ResponsiveScaler.width(20),
        top: ResponsiveScaler.height(16),
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            ResponsiveScaler.height(20),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveScaler.height(-4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildResponsibleField(),
          SizedBox(height: ResponsiveScaler.height(12)),
          _buildSpecialEventToggle(),
          SizedBox(height: ResponsiveScaler.height(16)),
          _buildTotalDisplay(),
          SizedBox(height: ResponsiveScaler.height(16)),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // Campo de texto para responsable del pago
  Widget _buildResponsibleField() {
    return TextField(
      controller: _responsibleController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.poppins(
        fontSize: ResponsiveScaler.font(15),
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Responsable del pago (opcional)',
        hintStyle: GoogleFonts.poppins(
          fontSize: ResponsiveScaler.font(14),
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(
          Icons.account_circle_outlined,
          color: AppColors.primary,
          size: ResponsiveScaler.icon(22),
        ),
        filled: true,
        fillColor: AppColors.backgroundGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
          borderSide: BorderSide.none,
        ),
        contentPadding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Toggle para marcar evento especial
  Widget _buildSpecialEventToggle() {
    return GestureDetector(
      onTap: _toggleSpecialEvent,
      child: Container(
        padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        decoration: BoxDecoration(
          color: _isSpecialEvent
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
          border: _isSpecialEvent
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _isSpecialEvent ? Icons.celebration : Icons.celebration_outlined,
              color: _isSpecialEvent ? AppColors.primary : AppColors.iconMuted,
              size: ResponsiveScaler.icon(20),
            ),
            SizedBox(width: ResponsiveScaler.width(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evento especial',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(14),
                      fontWeight: FontWeight.w500,
                      color: _isSpecialEvent
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Concierto, partido, feria u otro evento cercano',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(11),
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isSpecialEvent,
              onChanged: (value) {
                setState(() => _isSpecialEvent = value);
                _notifyValuesChanged();
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // Contenedor del monto total
  Widget _buildTotalDisplay() {
    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.totalAmountBackground,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'S/ ${widget.totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(24),
              fontWeight: FontWeight.bold,
              foreground: AppGradients.totalAmountText,
            ),
          ),
        ],
      ),
    );
  }

  // Botón de confirmación
  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onConfirm,
      child: Container(
        width: double.infinity,
        padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(vertical: 16),
        ),
        decoration: BoxDecoration(
          gradient: widget.isLoading ? null : AppGradients.primaryButton,
          color: widget.isLoading ? AppColors.backgroundDisabled : null,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
          boxShadow: !widget.isLoading
              ? [
                  BoxShadow(
                    color: AppColors.shadowPurple,
                    blurRadius: 12,
                    offset: Offset(0, ResponsiveScaler.height(4)),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? AppLoader(size: 22)
              : Text(
                  'Confirmar Pedido',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
