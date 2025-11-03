import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Card informativo de QUHO
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: padding ?? AppSpacing.paddingMd,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                AppSpacing.horizontalMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5(),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.verticalXxs,
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                AppSpacing.horizontalMd,
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

