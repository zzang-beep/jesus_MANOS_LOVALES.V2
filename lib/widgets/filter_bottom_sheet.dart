import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onSelected;

  const FilterBottomSheet({
    Key? key,
    required this.title,
    required this.icon,
    required this.options,
    this.selectedOption,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[300]),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Opción "Todos" o "Limpiar"
          _buildOption(
            context,
            label: 'Limpiar filtro',
            value: null,
            isSelected: selectedOption == null,
          ),

          const Divider(color: Colors.grey),

          // Opciones
          ...options.map((option) {
            return _buildOption(
              context,
              label: option,
              value: option,
              isSelected: selectedOption == option,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required String? value,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue[300] : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: Colors.blue[300]),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
