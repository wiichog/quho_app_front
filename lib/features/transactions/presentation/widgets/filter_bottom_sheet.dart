import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Bottom sheet para filtrar transacciones
class FilterBottomSheet extends StatefulWidget {
  final String? initialType;
  final String? initialCategory;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(String?, String?, DateTime?, DateTime?) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialType,
    this.initialCategory,
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedType;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = widget.initialCategory;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    widget.onApply(_selectedType, _selectedCategory, _startDate, _endDate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar Transacciones',
                    style: AppTextStyles.h4(),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray600,
                  ),
                ],
              ),

              AppSpacing.verticalLg,

              // Tipo de transacción
              Text(
                'Tipo',
                style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
              ),
              AppSpacing.verticalSm,
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _selectedType == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = null;
                      });
                    },
                    selectedColor: AppColors.teal,
                    labelStyle: TextStyle(
                      color: _selectedType == null ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Ingresos'),
                    selected: _selectedType == 'income',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'income';
                      });
                    },
                    selectedColor: AppColors.green,
                    labelStyle: TextStyle(
                      color: _selectedType == 'income' ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Gastos'),
                    selected: _selectedType == 'expense',
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = 'expense';
                      });
                    },
                    selectedColor: AppColors.red,
                    labelStyle: TextStyle(
                      color: _selectedType == 'expense' ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalLg,

              // Rango de fechas
              Text(
                'Rango de Fechas',
                style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
              ),
              AppSpacing.verticalSm,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _startDate != null
                            ? Formatters.shortDate(_startDate!)
                            : 'Fecha inicio',
                        style: AppTextStyles.bodySmall(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray700,
                        side: const BorderSide(color: AppColors.gray300),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectEndDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _endDate != null
                            ? Formatters.shortDate(_endDate!)
                            : 'Fecha fin',
                        style: AppTextStyles.bodySmall(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray700,
                        side: const BorderSide(color: AppColors.gray300),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalXl,

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray700,
                        side: const BorderSide(color: AppColors.gray300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

