import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  final double? size;

  const AppLoader({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final progressIndicator = CircularProgressIndicator(
      strokeWidth: size != null ? 2.5 : 3.0,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );

    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: progressIndicator,
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            progressIndicator,
            if (message != null) ...[
              const SizedBox(height: 16.0),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}