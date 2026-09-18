import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _timerController = TextEditingController();
  final _cycleOnController = TextEditingController();
  final _cycleOffController = TextEditingController();

  @override
  void dispose() {
    _timerController.dispose();
    _cycleOnController.dispose();
    _cycleOffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BombaESP - Fase 20'),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado actual
                _buildStatusCard(context, bleProvider),
                const SizedBox(height: 24),

                // Manual
                _buildManualSection(context, bleProvider),
                const SizedBox(height: 24),

                // Timer
                _buildTimerSection(context, bleProvider),
                const SizedBox(height: 24),

                // Ciclos
                _buildCyclesSection(context, bleProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, BLEProvider bleProvider) {
    String modeText = 'Manual';
    if (bleProvider.currentMode == BLEProvider.MODE_TIMER) modeText = 'Timer';
    if (bleProvider.currentMode == BLEProvider.MODE_CYCLES) modeText = 'Ciclos';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado Actual',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Fila 1: Modo y LED
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      modeText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LED:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      bleProvider.ledState == 1 ? '🟢 ON' : '⚫ OFF',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bleProvider.ledState == 1
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (bleProvider.currentMode != BLEProvider.MODE_MANUAL) ...[
              const SizedBox(height: 16),

              // Fila 2: Tiempo y Fase (para ciclos)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo Restante:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${bleProvider.timeRemaining}s',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  if (bleProvider.currentMode == BLEProvider.MODE_CYCLES)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fase:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bleProvider.isOnPhase
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bleProvider.isOnPhase ? '▶ ON' : '⏸ OFF',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: bleProvider.isOnPhase
                                ? Colors.green
                                : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (bleProvider.currentMode == BLEProvider.MODE_CYCLES)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Fase:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${bleProvider.totalPhaseTime}s',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Barra de progreso
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: bleProvider.totalPhaseTime > 0
                    ? (bleProvider.timeRemaining / bleProvider.totalPhaseTime)
                    : 0,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bleProvider.isOnPhase ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualSection(BuildContext context, BLEProvider bleProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1️⃣ Control Manual',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => bleProvider.sendCommand(1, BLEProvider.MODE_MANUAL, 0, 0),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb, size: 32),
                          SizedBox(height: 4),
                          Text('Encender'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => bleProvider.sendCommand(0, BLEProvider.MODE_MANUAL, 0, 0),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 32),
                          SizedBox(height: 4),
                          Text('Apagar'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context, BLEProvider bleProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⏱️ Timer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Segundos (1-3600)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Ejemplo: 30',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  int duration = int.tryParse(_timerController.text) ?? 0;
                  if (duration > 0 && duration <= 3600) {
                    bleProvider.sendCommand(1, BLEProvider.MODE_TIMER, duration, 0);
                    _timerController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Timer iniciado: $duration segundos'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un valor entre 1 y 3600'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclesSection(BuildContext context, BLEProvider bleProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔄 Ciclos ON/OFF',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cycleOnController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Segundos ON (1-3600)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Ejemplo: 5',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cycleOffController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Segundos OFF (1-3600)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Ejemplo: 3',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  int onTime = int.tryParse(_cycleOnController.text) ?? 0;
                  int offTime = int.tryParse(_cycleOffController.text) ?? 0;

                  if (onTime > 0 && offTime > 0 && onTime <= 3600 && offTime <= 3600) {
                    bleProvider.sendCommand(1, BLEProvider.MODE_CYCLES, onTime, offTime);
                    _cycleOnController.clear();
                    _cycleOffController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ciclos iniciados: ${onTime}s ON / ${offTime}s OFF'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Valores deben estar entre 1 y 3600'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Ciclos'),
              ),
            ),
          ],
        ),
      ),
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
