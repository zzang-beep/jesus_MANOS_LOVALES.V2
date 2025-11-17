import 'package:flutter/material.dart';
import '../utils/initialize_all.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final MasterInitializer _initializer = MasterInitializer();
  bool _isLoading = false;
  String _status = '';

  Future<void> _runInitialization() async {
    setState(() {
      _isLoading = true;
      _status = 'Inicializando...';
    });

    try {
      await _initializer.initializeEverything();
      setState(() {
        _status = '✅ Inicialización completada';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _status = 'Verificando...';
    });

    try {
      await _initializer.checkStatus();
      setState(() {
        _status = '✅ Ver consola para detalles';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar'),
        content: const Text(
          '¿Eliminar TODOS los datos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Limpiando...';
    });

    try {
      await _initializer.cleanEverything();
      setState(() {
        _status = '✅ Base de datos limpiada';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _migrateUsers() async {
    setState(() {
      _isLoading = true;
      _status = 'Migrando usuarios...';
    });

    try {
      await _initializer.migrateExistingUsers();
      setState(() {
        _status = '✅ Usuarios migrados';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '⚠️ SOLO PARA DESARROLLO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_status, style: const TextStyle(fontSize: 14)),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runInitialization,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch),
              label: const Text('Inicializar TODO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _migrateUsers,
              icon: const Icon(Icons.upgrade),
              label: const Text('Migrar Usuarios Existentes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: const Icon(Icons.check_circle),
              label: const Text('Verificar Estado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _cleanAll,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Limpiar TODO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const Spacer(),

            const Text(
              'Ver consola para logs detallados',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
