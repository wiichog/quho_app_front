import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/core/utils/formatters.dart';

class EditableBalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback? onEdit;
  final VoidCallback? onBalanceAdjusted;

  const EditableBalanceCard({
    super.key,
    required this.balance,
    this.onEdit,
    this.onBalanceAdjusted,
  });

  @override
  State<EditableBalanceCard> createState() => _EditableBalanceCardState();
}

class _EditableBalanceCardState extends State<EditableBalanceCard> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.balance.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveChanges() async {
    final newBalanceText = _controller.text.trim();
    if (newBalanceText.isEmpty) {
      _showError('Por favor ingresa un balance válido');
      return;
    }

    final newBalance = double.tryParse(newBalanceText);
    if (newBalance == null) {
      _showError('Balance inválido');
      return;
    }

    // Si no hay diferencia, solo cerrar
    if ((newBalance - widget.balance).abs() < 0.01) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final datasource = getIt<DashboardRemoteDataSource>();
      
      // Llamada real al backend
      final result = await datasource.adjustBalance(newBalance: newBalance);

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      // Mostrar información del ajuste
      final adjustmentType = result['transaction']?['transaction_type'] ?? 'ajuste';
      final adjustmentAmount = result['transaction']?['amount'] ?? newBalance;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Balance ajustado exitosamente a ${Formatters.currency(newBalance)}\n'
            'Se creó un ${adjustmentType} de ${Formatters.currency(double.parse(adjustmentAmount.toString()))}',
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      widget.onBalanceAdjusted?.call();
      widget.onEdit?.call();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError('Error al ajustar balance: $e');
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.balance.toStringAsFixed(2);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        gradient: AppColors.gradientHero,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Disponible',
                style: AppTextStyles.bodyMedium(color: AppColors.white.withOpacity(0.9)),
              ),
              if (!_isEditing)
                InkWell(
                  onTap: _startEditing,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSm,
          if (_isEditing)
            Row(
              children: [
                Text(
                  'Q ',
                  style: AppTextStyles.h1(color: AppColors.white),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.h1(color: AppColors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: AppTextStyles.h1(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    autofocus: true,
                  ),
                ),
              ],
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.currency(widget.balance),
                style: AppTextStyles.h1(color: AppColors.white).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isEditing) ...[
            AppSpacing.verticalSm,
            Text(
              'Ingresa el balance real de tu cuenta bancaria',
              style: AppTextStyles.caption(color: AppColors.white.withOpacity(0.8)),
            ),
            AppSpacing.verticalMd,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _cancelEditing,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white),
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.teal,
                      disabledBackgroundColor: AppColors.gray300,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

