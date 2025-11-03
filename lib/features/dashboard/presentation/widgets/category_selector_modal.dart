import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

/// Modelo para representar una categoría
class CategoryItem {
  final int id;
  final String name;
  final String? icon;
  final String? color;

  const CategoryItem({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });
}

/// Modal para seleccionar una categoría de una lista completa
class CategorySelectorModal extends StatefulWidget {
  final List<CategoryItem> categories;
  final Function(CategoryItem, bool) onCategorySelected;

  const CategorySelectorModal({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectorModal> createState() => _CategorySelectorModalState();
}

class _CategorySelectorModalState extends State<CategorySelectorModal> {
  String _searchQuery = '';
  bool _updateMerchant = false;

  List<CategoryItem> get filteredCategories {
    if (_searchQuery.isEmpty) {
      return widget.categories;
    }
    return widget.categories
        .where((category) =>
            category.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar Categoría',
                  style: AppTextStyles.h4().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar categoría...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Checkbox para actualizar merchant
            CheckboxListTile(
              title: Text(
                'Recordar para este establecimiento',
                style: AppTextStyles.bodyMedium(),
              ),
              subtitle: Text(
                'La próxima vez, se categorizará automáticamente',
                style: AppTextStyles.caption().copyWith(
                  color: AppColors.gray600,
                ),
              ),
              value: _updateMerchant,
              onChanged: (value) {
                setState(() {
                  _updateMerchant = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.teal,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Lista de categorías
            Expanded(
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron categorías',
                            style: AppTextStyles.bodyMedium().copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return _buildCategoryTile(category);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryItem category) {
    return ListTile(
      leading: category.icon != null
          ? Icon(
              _getIconFromString(category.icon!),
              size: 28,
              color: AppColors.teal,
            )
          : Icon(Icons.category, color: AppColors.gray600),
      title: Text(
        category.name,
        style: AppTextStyles.bodyMedium(),
      ),
      trailing: const Icon(Icons.check_circle_outline, color: AppColors.teal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onCategorySelected(category, _updateMerchant);
      },
      hoverColor: AppColors.gray100,
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

