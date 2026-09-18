import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BLEProvider extends ChangeNotifier {
  // Estado
  bool _isScanning = false;
  bool _isConnected = false;
  bool _ledState = false;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _ledCharacteristic;

  final List<BluetoothDevice> _devices = [];
  late StreamSubscription _scanSubscription;
  late StreamSubscription _connectionSubscription;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get ledState => _ledState;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDevice> get devices => _devices;

  // UUID de la ESP32
  static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String ledCharacteristicUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  // PIN de seguridad
  static const String BLE_PIN = '1357';

  // Iniciar escaneo de dispositivos
  Future<void> startScan() async {
    if (_isScanning) return;

    _devices.clear();
    _isScanning = true;
    notifyListeners();

    try {
      debugPrint('🔍 Starting BLE scan...');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          debugPrint('📡 Scan results: ${results.length} devices found');
          for (ScanResult r in results) {
            debugPrint('  - ${r.device.name} (${r.device.id})');
            if (!_devices.contains(r.device)) {
              _devices.add(r.device);
            }
          }
          notifyListeners();
        },
      );

      debugPrint('⏳ Waiting for scan to complete...');
      await Future.delayed(const Duration(seconds: 10));
      await stopScan();
    } catch (e) {
      debugPrint('❌ Error durante escaneo: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  // Detener escaneo
  Future<void> stopScan() async {
    _isScanning = false;
    await FlutterBluePlus.stopScan();
    _scanSubscription.cancel();
    notifyListeners();
  }

  // Validar PIN de seguridad
  Future<bool> validatePIN(String userInput) async {
    return userInput == BLE_PIN;
  }

  // Conectar a dispositivo
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      // Escuchar cambios de conexión
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          notifyListeners();
        }
      });

      // Obtener servicios
      final services = await device.discoverServices();

      // Buscar el servicio y característica
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                ledCharacteristicUUID.toLowerCase()) {
              _ledCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (_ledCharacteristic != null) {
        _isConnected = true;
        notifyListeners();
        return true;
      } else {
        debugPrint('Característica LED no encontrada');
        debugPrint('Servicios encontrados:');
        for (var service in services) {
          debugPrint('  Servicio: ${service.uuid}');
          for (var characteristic in service.characteristics) {
            debugPrint('    - ${characteristic.uuid}');
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error conectando: $e');
      return false;
    }
  }

  // Desconectar
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _isConnected = false;
      _connectedDevice = null;
      _ledCharacteristic = null;
      _connectionSubscription.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint('Error desconectando: $e');
    }
  }

  // Enviar comando LED con PIN (Fase 11)
  Future<void> toggleLED() async {
    if (_ledCharacteristic == null) return;

    final newState = !_ledState;

    // Protocolo Fase 11: [PIN (4 bytes ASCII)] + [Command (1 byte)]
    // PIN "1357" → [0x31, 0x33, 0x35, 0x37]
    final List<int> pinBytes = BLE_PIN.codeUnits;
    final List<int> value = [
      ...pinBytes,
      newState ? 1 : 0,
    ];

    try {
      debugPrint('💡 Writing LED state: ${newState ? 'ON' : 'OFF'} with PIN');
      await _ledCharacteristic!.write(value, withoutResponse: false);

      _ledState = newState;
      debugPrint('✅ LED state changed successfully (PIN validated by firmware)');
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('❌ Error enviando comando: $e');
      if (e.toString().contains('5') || e.toString().contains('INSUF_AUTHENTICATION')) {
        debugPrint('🚨 PIN incorrecto o comando rechazado por firmware');
      }
      notifyListeners();
    }
  }

  // Encender LED
  Future<void> ledOn() async {
    if (!_ledState) {
      debugPrint('🟢 Turning LED ON');
      await toggleLED();
    } else {
      debugPrint('⚠️ LED already ON');
    }
  }

  // Apagar LED
  Future<void> ledOff() async {
    if (_ledState) {
      debugPrint('🔴 Turning LED OFF');
      await toggleLED();
    } else {
      debugPrint('⚠️ LED already OFF');
    }
  }

  @override
  void dispose() {
    try {
      _scanSubscription.cancel();
      _connectionSubscription.cancel();
    } catch (e) {
      debugPrint('Error en dispose: $e');
    }
    disconnect();
    super.dispose();
  }
}
