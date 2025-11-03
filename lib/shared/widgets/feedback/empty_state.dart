import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Estado vacío de QUHO
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            
            AppSpacing.verticalLg,
            
            // Title
            Text(
              title,
              style: AppTextStyles.h3(),
              textAlign: TextAlign.center,
            ),
            
            if (message != null) ...[
              AppSpacing.verticalSm,
              Text(
                message!,
                style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (actionText != null && onActionPressed != null) ...[
              AppSpacing.verticalLg,
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

