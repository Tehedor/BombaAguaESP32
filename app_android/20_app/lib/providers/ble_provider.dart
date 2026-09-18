import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BLEProvider extends ChangeNotifier {
  // Estado
  bool _isScanning = false;
  bool _isConnected = false;
  int _ledState = 0;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _ledCharacteristic;

  final List<BluetoothDevice> _devices = [];
  late StreamSubscription _scanSubscription;
  late StreamSubscription _connectionSubscription;
  StreamSubscription? _notificationSubscription;

  // UUID y PIN
  static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String ledCharacteristicUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String BLE_PIN = '1357';

  // Modos
  static const int MODE_MANUAL = 0;
  static const int MODE_TIMER = 1;
  static const int MODE_CYCLES = 2;

  // Estado de operación - SINCRONIZADO DEL ESP32
  int _currentMode = MODE_MANUAL;
  int _timeRemaining = 0;
  int _totalPhaseTime = 0;
  bool _isOnPhase = false;
  int _ledStateDirect = 0;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  int get ledState => _ledStateDirect;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDevice> get devices => _devices;
  int get currentMode => _currentMode;
  int get timeRemaining => _timeRemaining;
  int get totalPhaseTime => _totalPhaseTime;
  bool get isOnPhase => _isOnPhase;

  Future<bool> validatePIN(String userInput) async {
    return userInput == BLE_PIN;
  }

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

  Future<void> stopScan() async {
    _isScanning = false;
    await FlutterBluePlus.stopScan();
    _scanSubscription.cancel();
    notifyListeners();
  }

  void _setupNotificationListener() {
    if (_ledCharacteristic == null) return;

    _notificationSubscription = _ledCharacteristic!.onValueReceived.listen(
      (value) {
        _processStatusUpdate(value);
      },
      onError: (e) {
        debugPrint('❌ Error in notification stream: $e');
      },
    );
  }

  void _processStatusUpdate(List<int> data) {
    if (data.length < 10) {
      debugPrint('⚠️ Status update incompleto: ${data.length} bytes');
      return;
    }

    // Parsear protocolo extendido (10 bytes)
    int mode = data[0];
    int timeRemaining = data[1] | (data[2] << 8);
    int totalPhaseTime = data[3] | (data[4] << 8);
    int ledState = data[5];
    bool isOnPhase = (data[6] & 0x01) == 0x00;

    // Actualizar estado directamente del ESP32
    _currentMode = mode;
    _timeRemaining = timeRemaining;
    _totalPhaseTime = totalPhaseTime;
    _ledStateDirect = ledState;
    _isOnPhase = isOnPhase;

    debugPrint(
      '📊 Sync ESP32: mode=$mode, phase=${isOnPhase ? "ON" : "OFF"}, '
      'time=$timeRemaining, totalPhase=$totalPhaseTime, led=$ledState',
    );

    notifyListeners();
  }

  Future<void> _requestStatus() async {
    if (_ledCharacteristic == null) return;

    try {
      // Enviar comando GET_STATUS: PIN + 0xFF
      final List<int> statusRequest = [
        0x31, 0x33, 0x35, 0x37, // "1357" (PIN)
        0xFF, // GET_STATUS command
      ];

      await _ledCharacteristic!.write(statusRequest, withoutResponse: false);
      debugPrint('📊 GET_STATUS requested');
    } catch (e) {
      debugPrint('❌ Error requesting status: $e');
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _currentMode = MODE_MANUAL;
          notifyListeners();
        }
      });

      final services = await device.discoverServices();

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
        // Habilitar notificaciones
        await _ledCharacteristic!.setNotifyValue(true);
        _setupNotificationListener();

        _isConnected = true;
        notifyListeners();

        // Solicitar estado actual del ESP32
        await Future.delayed(const Duration(milliseconds: 500));
        await _requestStatus();

        return true;
      } else {
        debugPrint('❌ Característica LED no encontrada');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error conectando: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _notificationSubscription?.cancel();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _isConnected = false;
      _connectedDevice = null;
      _ledCharacteristic = null;
      _currentMode = MODE_MANUAL;
      _connectionSubscription.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error desconectando: $e');
    }
  }

  // Protocolo: [PIN: 4 bytes] [CMD: 1] [TIPO: 1] [PARAM1: 2] [PARAM2: 2]
  Future<void> sendCommand(int cmd, int mode, int param1, int param2) async {
    if (_ledCharacteristic == null) return;

    try {
      final List<int> pinBytes = BLE_PIN.codeUnits;
      final List<int> value = [
        ...pinBytes,
        cmd,
        mode,
        param1 & 0xFF,
        (param1 >> 8) & 0xFF,
        param2 & 0xFF,
        (param2 >> 8) & 0xFF,
      ];

      String modeStr = '';
      if (mode == MODE_MANUAL) modeStr = 'MANUAL';
      else if (mode == MODE_TIMER) modeStr = 'TIMER(${param1}s)';
      else if (mode == MODE_CYCLES) modeStr = 'CICLOS(${param1}s ON/${param2}s OFF)';

      debugPrint('💡 Enviando: $modeStr');
      await _ledCharacteristic!.write(value, withoutResponse: false);
      debugPrint('✅ Comando enviado');

      // Esperar a que el ESP32 responda con el estado
      await Future.delayed(const Duration(milliseconds: 500));
      await _requestStatus();
    } catch (e) {
      debugPrint('❌ Error enviando comando: $e');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _connectionSubscription.cancel();
    super.dispose();
  }
}
