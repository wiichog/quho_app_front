import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

/// Modal para categorizar transacciones con 3 opciones:
/// 1. Aceptar categoría sugerida
/// 2. Abrir modal con lista de todas las categorías
/// 3. Cancelar (cerrar modal)
class CategorizationModal extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onAcceptSuggestion;
  final VoidCallback onBrowseCategories;

  const CategorizationModal({
    Key? key,
    required this.transaction,
    required this.onAcceptSuggestion,
    required this.onBrowseCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestedCategory = transaction.suggestedCategory;
    final hasSuggestion = suggestedCategory != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Text(
              'Categorizar Transacción',
              style: AppTextStyles.h4().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Información de la transacción
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currency(transaction.amount),
                        style: AppTextStyles.h5().copyWith(
                          color: transaction.isIncome ? AppColors.green : AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (transaction.merchantDisplayName != null)
                        Text(
                          '🏪 ${transaction.merchantDisplayName}',
                          style: AppTextStyles.caption().copyWith(
                            color: AppColors.gray700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botón 1: Aceptar categoría sugerida (si existe)
            if (hasSuggestion) ...[
              _buildSuggestionCard(suggestedCategory),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onAcceptSuggestion,
                icon: const Icon(Icons.check_circle),
                label: Text('Aceptar Categoría Sugerida'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'o',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption().copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Botón 2: Elegir otra categoría
            OutlinedButton.icon(
              onPressed: onBrowseCategories,
              icon: const Icon(Icons.category),
              label: Text('Elegir Otra Categoría'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teal,
                side: BorderSide(color: AppColors.teal, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón 3: Cancelar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.bodyMedium().copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(SuggestedCategory suggestion) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tealPale,
        border: Border.all(color: AppColors.teal, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Icono de la categoría
          if (suggestion.icon != null)
            Icon(
              _getIconFromString(suggestion.icon!),
              size: 32,
              color: AppColors.teal,
            ),
          if (suggestion.icon != null) const SizedBox(width: 12),
          
          // Información de la categoría
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    suggestion.displayName,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      suggestion.source == 'merchant' 
                          ? Icons.store 
                          : Icons.smart_toy,
                      size: 14,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        suggestion.source == 'merchant' 
                            ? 'Del establecimiento' 
                            : 'Sugerencia IA',
                        style: AppTextStyles.caption().copyWith(
                          color: AppColors.gray600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(suggestion.confidence * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.caption().copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Mapea un string de icono a un IconData de Material Icons
  IconData _getIconFromString(String iconName) {
    final iconMap = {
      // Alimentación
      'restaurant': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'delivery_dining': Icons.delivery_dining,
      'local_cafe': Icons.local_cafe,
      
      // Transporte
      'directions_car': Icons.directions_car,
      'local_gas_station': Icons.local_gas_station,
      'directions_bus': Icons.directions_bus,
      'local_taxi': Icons.local_taxi,
      'build': Icons.build,
      
      // Vivienda
      'home': Icons.home,
      'home_work': Icons.home_work,
      'electrical_services': Icons.electrical_services,
      'handyman': Icons.handyman,
      'wifi': Icons.wifi,
      
      // Deudas
      'credit_card': Icons.credit_card,
      'account_balance': Icons.account_balance,
      'house': Icons.house,
      
      // Salud
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'medication': Icons.medication,
      'health_and_safety': Icons.health_and_safety,
      'dentistry': Icons.health_and_safety,
      
      // Educación
      'school': Icons.school,
      'menu_book': Icons.menu_book,
      'book': Icons.book,
      
      // Entretenimiento
      'theaters': Icons.theaters,
      'tv': Icons.tv,
      'local_movies': Icons.local_movies,
      'celebration': Icons.celebration,
      'sports_esports': Icons.sports_esports,
      
      // Mascotas
      'pets': Icons.pets,
      'pet_supplies': Icons.pets,
      'cut': Icons.content_cut,
      
      // Compras
      'shopping_bag': Icons.shopping_bag,
      'checkroom': Icons.checkroom,
      'devices': Icons.devices,
      'face': Icons.face,
      
      // Suscripciones
      'subscriptions': Icons.subscriptions,
      'library_music': Icons.library_music,
      'fitness_center': Icons.fitness_center,
      
      // Impuestos
      'receipt': Icons.receipt,
      'location_city': Icons.location_city,
      
      // Otros
      'more_horiz': Icons.more_horiz,
      'receipt_long': Icons.receipt_long,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }
}

