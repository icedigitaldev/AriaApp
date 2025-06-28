import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../utils/logger.dart';

class KitchenOrderDetailsView extends StatefulWidget {
  const KitchenOrderDetailsView({Key? key}) : super(key: key);

  @override
  State<KitchenOrderDetailsView> createState() => _KitchenOrderDetailsViewState();
}

class _KitchenOrderDetailsViewState extends State<KitchenOrderDetailsView> {
  bool isLoading = false;
  Map<int, bool> itemStatus = {};

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (order == null) {
      return const Scaffold(
        body: Center(
          child: Text('No se encontró información de la orden'),
        ),
      );
    }

    final timeDiff = _getTimeDifference(order['orderTime']);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(
        backgroundColor: Color(0xFFF3E5F5),
        statusBarIconBrightness: Brightness.dark,
      ),
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
          child: Column(
            children: [
              _buildHeader(order, timeDiff),
              Expanded(
                child: _buildOrderContent(order),
              ),
              _buildActionButtons(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> order, String timeDiff) {
    final statusConfig = _getStatusConfig(order['status']);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #${order['id']}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              Color(0xFF7B1FA2),
                              Color(0xFFE91E63),
                            ],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    Text(
                      'Mesa ${order['tableNumber']} • ${order['waiter']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusConfig['backgroundColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusConfig['dotColor'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusConfig['text'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusConfig['textColor'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Hora de pedido',
                  value: order['time'],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildInfoItem(
                  icon: Icons.timer,
                  label: 'Tiempo transcurrido',
                  value: timeDiff,
                  valueColor: timeDiff.contains('min') && int.parse(timeDiff.split(' ')[0]) > 15
                      ? Colors.red[600]
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderContent(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elementos del pedido',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: order['items'].length,
              itemBuilder: (context, index) {
                final item = order['items'][index];
                return _buildDetailedOrderItem(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedOrderItem(Map<String, dynamic> item, int index) {
    final isCompleted = itemStatus[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? const Color(0xFF81C784) : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              itemStatus[index] = !isCompleted;
            });
            AppLogger.log('Item ${isCompleted ? "desmarcado" : "marcado"}: ${item['name']}', prefix: 'COCINA:');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF66BB6A),
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xFFF3E5F5),
                        Color(0xFFFCE4EC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                        : Text(
                      item['quantity'].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['notes'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[400],
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final allItemsCompleted = order['items'].asMap().entries.every(
          (entry) => itemStatus[entry.key] ?? false,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (order['status'] == 'pending')
            Expanded(
              child: GestureDetector(
                onTap: isLoading ? null : () => _updateOrderStatus('preparing'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF64B5F6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'Comenzar Preparación',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (order['status'] == 'preparing') ...[
            Expanded(
              child: GestureDetector(
                onTap: isLoading ? null : () => _cancelPreparation(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isLoading || !allItemsCompleted ? null : () => _updateOrderStatus('ready'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: allItemsCompleted
                          ? [
                        const Color(0xFF4CAF50),
                        const Color(0xFF66BB6A),
                      ]
                          : [Colors.grey[400]!, Colors.grey[400]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: allItemsCompleted
                        ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Marcar como Listo',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _updateOrderStatus(String newStatus) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    AppLogger.log('Estado actualizado a: $newStatus', prefix: 'COCINA:');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'preparing' ? 'Preparación iniciada' : 'Orden lista para servir',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, {'status': newStatus});
    }
  }

  void _cancelPreparation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cancelar preparación',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar la preparación de esta orden?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus('pending');
            },
            child: Text(
              'Sí, cancelar',
              style: GoogleFonts.poppins(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeDifference(DateTime orderTime) {
    final difference = DateTime.now().difference(orderTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}min';
    }
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return {
          'backgroundColor': const Color(0xFFFFF3E0),
          'borderColor': const Color(0xFFFFB74D),
          'textColor': const Color(0xFFF57C00),
          'dotColor': const Color(0xFFFF9800),
          'text': 'Pendiente',
        };
      case 'preparing':
        return {
          'backgroundColor': const Color(0xFFE3F2FD),
          'borderColor': const Color(0xFF64B5F6),
          'textColor': const Color(0xFF1976D2),
          'dotColor': const Color(0xFF2196F3),
          'text': 'Preparando',
        };
      case 'ready':
        return {
          'backgroundColor': const Color(0xFFE8F5E9),
          'borderColor': const Color(0xFF81C784),
          'textColor': const Color(0xFF388E3C),
          'dotColor': const Color(0xFF4CAF50),
          'text': 'Listo',
        };
      default:
        return {
          'backgroundColor': Colors.grey[100]!,
          'borderColor': Colors.grey[300]!,
          'textColor': Colors.grey[700]!,
          'dotColor': Colors.grey[500]!,
          'text': 'Desconocido',
        };
    }
  }
}