import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BombaESP'),
        elevation: 0,
      ),
      body: Consumer<BLEProvider>(
        builder: (context, bleProvider, _) {
          if (!bleProvider.isConnected) {
            return _buildNotConnected(context, bleProvider);
          }
          return _buildConnected(context, bleProvider);
        },
      ),
    );
  }

  Widget _buildNotConnected(BuildContext context, BLEProvider bleProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No conectado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Conecta con una ESP32 cercana',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('Escanear dispositivos'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnected(BuildContext context, BLEProvider bleProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con dispositivo conectado
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: Row(
            children: [
              Icon(
                Icons.bluetooth_connected,
                color: Colors.green[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conectado a:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      bleProvider.connectedDevice?.name ?? 'Dispositivo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => _showDisconnectDialog(context, bleProvider),
                child: const Text('Desconectar'),
              ),
            ],
          ),
        ),

        // Contenido principal
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Control LED
                Text(
                  'Control de LED',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),

                // Toggle LED grande
                GestureDetector(
                  onTap: () => bleProvider.toggleLED(),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bleProvider.ledState
                          ? Colors.yellow[400]
                          : Colors.grey[300],
                      boxShadow: [
                        BoxShadow(
                          color: (bleProvider.ledState
                              ? Colors.yellow
                              : Colors.grey)
                              .withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          bleProvider.ledState
                              ? Icons.lightbulb
                              : Icons.lightbulb_outline,
                          size: 80,
                          color: bleProvider.ledState
                              ? Colors.orange
                              : Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bleProvider.ledState ? 'ON' : 'OFF',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: bleProvider.ledState
                                ? Colors.orange
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botones individuales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
                      onPressed: () => bleProvider.ledOn(),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Encender'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => bleProvider.ledOff(),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Apagar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDisconnectDialog(BuildContext context, BLEProvider bleProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text('¿Desconectar del dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              bleProvider.disconnect();
              Navigator.pop(context);
            },
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }
}
