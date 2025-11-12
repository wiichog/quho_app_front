import 'package:flutter/material.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Bottom sheet para filtrar transacciones
class FilterBottomSheet extends StatefulWidget {
  final String? initialType;
  final String? initialCategory;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(String?, String?, String?, DateTime?, DateTime?) onApply; // type, categoryId, categoryName, startDate, endDate

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
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<CategoryModel> _categories = [];
  List<IncomeSourceModel> _incomeSources = [];
  bool _isLoadingCategories = false;
  bool _isLoadingIncomeSources = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategoryId = widget.initialCategory;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    
    // Cargar categorías y fuentes de ingreso
    _loadCategories();
    _loadIncomeSources();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      final datasource = getIt<DashboardRemoteDataSource>();
      final categories = await datasource.getCategories();
      setState(() {
        _categories = categories;
        // Si hay una categoría inicial seleccionada, buscar su nombre
        if (_selectedCategoryId != null && _selectedCategoryName == null) {
          try {
            final categoryId = int.parse(_selectedCategoryId!);
            final category = categories.firstWhere(
              (cat) => cat.id == categoryId,
              orElse: () => categories.first,
            );
            _selectedCategoryName = category.displayName;
          } catch (e) {
            // Si no es numérico, buscar por slug
            final category = categories.firstWhere(
              (cat) => cat.slug == _selectedCategoryId,
              orElse: () => categories.first,
            );
            _selectedCategoryId = category.id.toString();
            _selectedCategoryName = category.displayName;
          }
        }
      });
    } catch (e) {
      print('[FilterBottomSheet] Error cargando categorías: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadIncomeSources() async {
    setState(() {
      _isLoadingIncomeSources = true;
    });
    
    try {
      final datasource = getIt<DashboardRemoteDataSource>();
      final incomeSources = await datasource.getIncomeSources();
      setState(() {
        _incomeSources = incomeSources;
        // Si hay una categoría inicial seleccionada y es tipo income, buscar su nombre
        if (_selectedType == 'income' && _selectedCategoryId != null && _selectedCategoryName == null) {
          try {
            final categoryId = int.parse(_selectedCategoryId!);
            final incomeSource = incomeSources.firstWhere(
              (source) => source.id == categoryId,
              orElse: () => incomeSources.first,
            );
            _selectedCategoryName = incomeSource.name;
          } catch (e) {
            // Si no se encuentra, usar el ID como nombre
            _selectedCategoryName = _selectedCategoryId;
          }
        }
      });
    } catch (e) {
      print('[FilterBottomSheet] Error cargando fuentes de ingreso: $e');
    } finally {
      setState(() {
        _isLoadingIncomeSources = false;
      });
    }
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
      _selectedCategoryId = null;
      _selectedCategoryName = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    widget.onApply(_selectedType, _selectedCategoryId, _selectedCategoryName, _startDate, _endDate);
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
          child: SingleChildScrollView(
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
                          _selectedCategoryId = null;
                          _selectedCategoryName = null;
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
                          // Limpiar categoría de gastos si estaba seleccionada
                          if (_selectedCategoryId != null && _categories.any((c) => c.id.toString() == _selectedCategoryId)) {
                            _selectedCategoryId = null;
                            _selectedCategoryName = null;
                          }
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
                          // Limpiar fuente de ingreso si estaba seleccionada
                          if (_selectedCategoryId != null && _incomeSources.any((s) => s.id.toString() == _selectedCategoryId)) {
                            _selectedCategoryId = null;
                            _selectedCategoryName = null;
                          }
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

                // Selector de categoría/fuente de ingreso
                if (_selectedType != null) ...[
                  Text(
                    _selectedType == 'income' ? 'Fuente de Ingreso' : 'Categoría',
                    style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
                  ),
                  AppSpacing.verticalSm,
                  if (_selectedType == 'expense' && _isLoadingCategories)
                    const Center(child: CircularProgressIndicator())
                  else if (_selectedType == 'expense' && _categories.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          hint: Text(
                            'Seleccionar categoría',
                            style: AppTextStyles.bodyMedium().copyWith(color: AppColors.gray500),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Todas las categorías',
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ),
                            ..._categories.map((category) {
                              final categoryColor = category.color != null && category.color!.isNotEmpty
                                  ? Color(int.parse('0xFF${category.color!.substring(1)}'))
                                  : AppColors.gray400;
                              
                              return DropdownMenuItem<String>(
                                value: category.id.toString(),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        category.displayName,
                                        style: AppTextStyles.bodyMedium(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                              if (value != null) {
                                final category = _categories.firstWhere(
                                  (cat) => cat.id.toString() == value,
                                );
                                _selectedCategoryName = category.displayName;
                              } else {
                                _selectedCategoryName = null;
                              }
                            });
                          },
                        ),
                      ),
                    )
                  else if (_selectedType == 'income' && _isLoadingIncomeSources)
                    const Center(child: CircularProgressIndicator())
                  else if (_selectedType == 'income' && _incomeSources.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          hint: Text(
                            'Seleccionar fuente de ingreso',
                            style: AppTextStyles.bodyMedium().copyWith(color: AppColors.gray500),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Todas las fuentes',
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ),
                            ..._incomeSources.map((source) {
                              return DropdownMenuItem<String>(
                                value: source.id.toString(),
                                child: Text(
                                  source.name,
                                  style: AppTextStyles.bodyMedium(),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                              if (value != null) {
                                final source = _incomeSources.firstWhere(
                                  (s) => s.id.toString() == value,
                                );
                                _selectedCategoryName = source.name;
                              } else {
                                _selectedCategoryName = null;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  AppSpacing.verticalLg,
                ],

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
      ),
    );
  }
}
