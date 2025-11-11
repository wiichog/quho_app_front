import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:intl/intl.dart';

/// Bottom sheet para editar una transacción
class EditTransactionBottomSheet extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionBottomSheet> createState() => _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState extends State<EditTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  
  late String _selectedType; // 'expense' | 'income'
  late DateTime _selectedDate;
  late String _selectedCurrency;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.abs().toString());
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDate));
    _selectedCurrency = 'GTQ'; // TODO: Get from transaction or user preferences

    // Escuchar cambios
    _descriptionController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Aquí iría la llamada al API para actualizar la transacción
      // Por ahora, simularemos el éxito
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transacción actualizada exitosamente'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Recargar dashboard
      final bloc = getIt<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _toggleIgnored() async {
    final shouldIgnore = !widget.transaction.isIgnored;
    final action = shouldIgnore ? 'ignorar' : 'restaurar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          shouldIgnore ? 'Ignorar transacción' : 'Restaurar transacción',
          style: AppTextStyles.h5(),
        ),
        content: Text(
          shouldIgnore
              ? '¿Estás seguro de que deseas ignorar esta transacción? No se mostrará en "Por Categorizar".'
              : '¿Deseas volver a considerar esta transacción? Aparecerá en "Por Categorizar" si no está categorizada.',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldIgnore ? AppColors.orange : AppColors.teal,
            ),
            child: Text(shouldIgnore ? 'Sí, ignorar' : 'Sí, restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final datasource = getIt<DashboardRemoteDataSource>();
      await datasource.ignoreTransaction(
        transactionId: widget.transaction.id,
        isIgnored: shouldIgnore,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transacción ${shouldIgnore ? "ignorada" : "restaurada"} exitosamente'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Recargar dashboard
      final bloc = getIt<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al $action: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _recategorize() async {
    // Cerrar el modal actual
    Navigator.of(context).pop();

    // Aquí el usuario debería poder abrir el modal de categorización
    // Esto requeriría acceso al método de categorización desde el dashboard
    // Por ahora, mostraremos un mensaje informativo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abre la transacción desde "Por Categorizar" para cambiar su categoría'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Eliminar transacción', style: AppTextStyles.h5()),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      // Aquí iría la llamada al API para eliminar
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción eliminada exitosamente'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Recargar dashboard
      final bloc = getIt<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar Transacción',
                        style: AppTextStyles.h4(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                AppSpacing.verticalMd,

                // Tipo
                Text(
                  'Tipo',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    Expanded(
                  child: _TypeChip(
                    label: 'Gasto',
                    icon: Icons.arrow_downward,
                    color: AppColors.red,
                    isSelected: _selectedType == 'expense',
                    onTap: () {
                      setState(() {
                        _selectedType = 'expense';
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeChip(
                    label: 'Ingreso',
                    icon: Icons.arrow_upward,
                    color: AppColors.green,
                    isSelected: _selectedType == 'income',
                    onTap: () {
                      setState(() {
                        _selectedType = 'income';
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
                  ],
                ),

                AppSpacing.verticalMd,

                // Descripción
                Text(
                  'Descripción',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
                AppSpacing.verticalSm,
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Descripción de la transacción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),

                AppSpacing.verticalMd,

                // Monto
                Text(
                  'Monto',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          prefixText: _selectedCurrency == 'GTQ' ? 'Q ' : '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un monto';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Monto inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedCurrency,
                        style: AppTextStyles.bodyMedium(),
                      ),
                    ),
                  ],
                ),

                AppSpacing.verticalMd,

                // Fecha
                Text(
                  'Fecha',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
                AppSpacing.verticalSm,
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                AppSpacing.verticalXl,

                // Botones de acción
                Column(
                  children: [
                    // Guardar cambios
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text('Guardar cambios'),
                      ),
                    ),

                    AppSpacing.verticalSm,

                    // Ignorar/Restaurar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _toggleIgnored,
                        icon: Icon(
                          widget.transaction.isIgnored ? Icons.visibility : Icons.visibility_off,
                        ),
                        label: Text(
                          widget.transaction.isIgnored ? 'Restaurar transacción' : 'Ignorar transacción',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.orange,
                          side: const BorderSide(color: AppColors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    AppSpacing.verticalSm,

                    // Recategorizar (solo si está categorizada)
                    if (widget.transaction.category != 'Sin categorizar')
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _recategorize,
                          icon: const Icon(Icons.category),
                          label: const Text('Cambiar categoría'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            side: const BorderSide(color: AppColors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                    AppSpacing.verticalSm,

                    // Eliminar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _deleteTransaction,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar transacción'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.gray500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall().copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

