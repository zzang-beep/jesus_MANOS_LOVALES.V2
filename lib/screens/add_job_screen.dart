import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/service_service.dart';
import '../services/category_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/service_model.dart';
import '../models/category_model.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _paymentController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _serviceService = ServiceService();
  final _categoryService = CategoryService();
  final _userService = UserService();

  List<CategoryModel> _categories = [];
  final List<CategoryModel> _fallbackCategories = [
    CategoryModel(
      categoryId: 'plomeria',
      name: 'Plomería',
      icon: 'plumbing',
      color: '#1976D2',
    ),
    CategoryModel(
      categoryId: 'electricidad',
      name: 'Electricidad',
      icon: 'electrical_services',
      color: '#F57C00',
    ),
    CategoryModel(
      categoryId: 'limpieza',
      name: 'Limpieza',
      icon: 'cleaning_services',
      color: '#00ACC1',
    ),
    CategoryModel(
      categoryId: 'jardineria',
      name: 'Jardinería',
      icon: 'yard',
      color: '#388E3C',
    ),
    CategoryModel(
      categoryId: 'clases',
      name: 'Clases y educación',
      icon: 'school',
      color: '#7B1FA2',
    ),
  ];
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      if (!mounted) return;
      final Map<String, CategoryModel> merged = {
        for (final category in _fallbackCategories) category.categoryId: category
      };
      for (final category in categories) {
        merged[category.categoryId] = category;
      }
      setState(() {
        _categories = merged.values.toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _categories = List.from(_fallbackCategories));
    }
  }

  Future<void> _publishJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de empleo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId == null) throw 'Debes iniciar sesión';

      final provider = await _userService.getUserById(userId);
      if (provider == null) throw 'Usuario no encontrado';

      final service = ServiceModel(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        price: _paymentController.text.isEmpty
            ? null
            : double.tryParse(_paymentController.text),
        priceText: _paymentController.text.isEmpty
            ? 'A convenir'
            : '\$${_paymentController.text}',
        providerId: provider.userId,
        providerName: provider.name,
        providerPhone: provider.phone,
        providerPhotoUrl: provider.photoUrl,
        locationText: _locationController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _serviceService.createService(service: service, provider: provider);

      // Mostrar modal de éxito
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Cerrar dialog
                      Navigator.pop(context); // Volver a home
                    },
                  ),
                ],
              ),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Publicación creada\ncorrectamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu servicio se ha publicado con éxito.\nPodrás verlo en Mis publicaciones o editarlo cuando quieras →',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000B1F),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Añadir puesto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título de Trabajo
                        _buildTextField(
                          controller: _titleController,
                          label: 'Título de Trabajo:',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Tipo de empleo
                        const Text(
                          'Tipo de empleo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001F3F),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF001F3F),
                              hint: const Text(
                                'Selecciona una categoría',
                                style: TextStyle(color: Colors.grey),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.categoryId,
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Ubicación
                        _buildTextField(
                          controller: _locationController,
                          label: 'Ubicación:',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Pago
                        _buildTextField(
                          controller: _paymentController,
                          label: 'Pago:',
                          keyboardType: TextInputType.number,
                          required: false,
                        ),

                        const SizedBox(height: 20),

                        // Descripción
                        const Text(
                          'Descripción:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001F3F),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: TextFormField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 6,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Describe el trabajo...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obligatorio';
                              }
                              if (value.length < 10) {
                                return 'Mínimo 10 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Botón Publicar
                        ElevatedButton(
                          onPressed: _isLoading ? null : _publishJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Publicar',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF001F3F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _paymentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
