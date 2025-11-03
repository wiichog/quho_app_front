import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Indicador de carga de QUHO
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.teal,
            ),
          ),
          if (message != null) ...[
            AppSpacing.verticalMd,
            Text(
              message!,
              style: AppTextStyles.bodyMedium(),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

