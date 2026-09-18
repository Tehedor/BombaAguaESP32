import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BLEProvider>().startScan();
    });
  }

  @override
  void dispose() {
    // Detener escaneo si está activo
    Future.microtask(() {
      if (mounted) {
        context.read<BLEProvider>().stopScan();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear dispositivos'),
      ),
      body: Consumer<BLEProvider>(
        builder: (context, bleProvider, _) {
          return Column(
            children: [
              // Indicador de escaneo
              if (bleProvider.isScanning)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Escaneando...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => bleProvider.startScan(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Escanear de nuevo'),
                  ),
                ),

              // Lista de dispositivos
              Expanded(
                child: bleProvider.devices.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_disabled,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron dispositivos',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: bleProvider.devices.length,
                      itemBuilder: (context, index) {
                        final device = bleProvider.devices[index];
                        return ListTile(
                          leading: Icon(
                            Icons.devices,
                            color: Colors.blue[700],
                          ),
                          title: Text(device.name.isEmpty
                              ? 'Dispositivo desconocido'
                              : device.name),
                          subtitle: Text(device.id.toString()),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            final pinController = TextEditingController();

                            // Pedir PIN de seguridad
                            final pinValid = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('🔐 PIN de Seguridad'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ingresa el PIN para conectar a ${device.name}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: pinController,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      decoration: InputDecoration(
                                        labelText: 'PIN',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 20, letterSpacing: 8),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () async {
                                      final isValid = await bleProvider.validatePIN(pinController.text);
                                      if (!context.mounted) return;
                                      Navigator.pop(context, isValid);
                                    },
                                    child: const Text('Conectar'),
                                  ),
                                ],
                              ),
                            ) ?? false;

                            if (!pinValid) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PIN incorrecto'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            if (!context.mounted) return;

                            // Mostrar loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Conectando a ${device.name}...',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );

                            // Intentar conectar
                            final success = await bleProvider.connect(device);

                            if (!mounted) return;
                            Navigator.pop(context); // Cerrar loading

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Conectado exitosamente'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context); // Volver a home
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al conectar'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
