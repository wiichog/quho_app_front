import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'dart:math' as math;

/// Financial Health Score widget
class FinancialHealthScore extends StatelessWidget {
  final double score; // 0-100
  final String description;

  const FinancialHealthScore({
    super.key,
    required this.score,
    required this.description,
  });

  Color _getScoreColor() {
    if (score >= 80) return AppColors.green;
    if (score >= 60) return AppColors.teal;
    if (score >= 40) return AppColors.orange;
    return AppColors.red;
  }

  String _getScoreLabel() {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Buena';
    if (score >= 40) return 'Regular';
    return 'Necesita Atención';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Salud Financiera',
            style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Score circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              // Score text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: AppTextStyles.h1().copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    _getScoreLabel(),
                    style: AppTextStyles.caption(color: AppColors.gray600),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: AppTextStyles.bodySmall().copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

