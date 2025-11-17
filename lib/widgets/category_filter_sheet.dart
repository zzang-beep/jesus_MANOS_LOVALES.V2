import 'package:flutter/material.dart';

class CategoryFilterSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onApply;

  const CategoryFilterSheet({
    Key? key,
    required this.selectedCategories,
    required this.onApply,
  }) : super(key: key);

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late List<String> _tempSelected;

  final List<Map<String, String>> _categories = [
    {'id': 'servicios_hogar', 'name': 'Servicios de Hogar'},
    {'id': 'servicio_personal', 'name': 'Servicio Personal'},
    {'id': 'tecnologia', 'name': 'Tecnología'},
    {'id': 'todos', 'name': 'Todos'},
    {'id': 'automacion', 'name': 'Automación'},
    {'id': 'educacion', 'name': 'Educación y clases'},
  ];

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lista desplegable',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Checkboxes
          ..._categories.map((category) {
            final isSelected = _tempSelected.contains(category['id']);
            return CheckboxListTile(
              title: Text(
                category['name']!,
                style: const TextStyle(color: Colors.white),
              ),
              value: isSelected,
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  if (category['id'] == 'todos') {
                    if (value == true) {
                      _tempSelected = ['todos'];
                    } else {
                      _tempSelected.clear();
                    }
                  } else {
                    if (value == true) {
                      _tempSelected.remove('todos');
                      _tempSelected.add(category['id']!);
                    } else {
                      _tempSelected.remove(category['id']);
                    }
                  }
                });
              },
            );
          }).toList(),

          const SizedBox(height: 20),

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_tempSelected);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Función helper para mostrar el bottom sheet
void showCategoryFilterSheet(
  BuildContext context, {
  required List<String> selectedCategories,
  required Function(List<String>) onApply,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CategoryFilterSheet(
      selectedCategories: selectedCategories,
      onApply: onApply,
    ),
  );
}
