import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

class NewIncomeSourceModal extends StatefulWidget {
  final Function(String name, double amount, String frequency, bool isNetAmount, String taxContext) onSubmit;
  final double? transactionAmount;

  const NewIncomeSourceModal({
    super.key,
    required this.onSubmit,
    this.transactionAmount,
  });

  @override
  State<NewIncomeSourceModal> createState() => _NewIncomeSourceModalState();
}

class _NewIncomeSourceModalState extends State<NewIncomeSourceModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _frequency = 'monthly';
  bool _isNetAmount = true;
  String _taxContext = 'other';

  @override
  void initState() {
    super.initState();
    // Si viene un monto de transacción, pre-llenarlo
    if (widget.transactionAmount != null) {
      _amountController.text = widget.transactionAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_business, color: AppColors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nueva Fuente de Ingreso',
              style: AppTextStyles.h4(),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              Text(
                'Nombre del ingreso',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: Trabajo Freelance, Consultoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monto
              Text(
                'Monto',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                enabled: widget.transactionAmount == null, // Bloqueado si viene de transacción
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'Q ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: widget.transactionAmount != null,
                  fillColor: widget.transactionAmount != null ? AppColors.gray100 : null,
                  suffixIcon: widget.transactionAmount != null 
                    ? Icon(Icons.lock, size: 18, color: AppColors.gray500)
                    : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              if (widget.transactionAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Monto tomado de la transacción',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                ),
              ],
              const SizedBox(height: 16),

              // Frecuencia
              Text(
                'Frecuencia',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'one_time', child: Text('Única vez')),
                  DropdownMenuItem(value: 'daily', child: Text('Diario')),
                  DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                  DropdownMenuItem(value: 'biweekly', child: Text('Quincenal')),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Tipo de monto
              Row(
                children: [
                  Checkbox(
                    value: _isNetAmount,
                    onChanged: (value) {
                      setState(() {
                        _isNetAmount = value ?? true;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Monto neto (después de impuestos)',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contexto fiscal
              Text(
                'Contexto fiscal',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _taxContext,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'invoice_small_taxpayer', child: Text('Factura Pequeño Contribuyente')),
                  DropdownMenuItem(value: 'invoice_general', child: Text('Factura General')),
                  DropdownMenuItem(value: 'payroll_igss', child: Text('Planilla con IGSS')),
                  DropdownMenuItem(value: 'payroll_no_igss', child: Text('Planilla sin IGSS')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _taxContext = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.gray600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              widget.onSubmit(
                _nameController.text,
                amount,
                _frequency,
                _isNetAmount,
                _taxContext,
              );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Guardar y Categorizar',
            style: AppTextStyles.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

