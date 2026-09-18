# BombaESP - App Flutter

App de control para la bomba de agua ESP32 vía Bluetooth BLE.

## 📦 Requisitos Previos

- **Flutter 3.0+** instalado (https://flutter.dev/docs/get-started/install)
- **Dart 3.0+**
- **Android SDK 31+** (para Android)
- **Xcode 14+** (para iOS, opcional)

## 🚀 Instalación

### 1. Verificar instalación de Flutter

```bash
flutter --version
flutter doctor
```

Asegúrate de que todo esté verde (✓).

### 2. Obtener dependencias

```bash
cd app_android
flutter pub get
```

Esto instalará todas las librerías definidas en `pubspec.yaml`.

### 3. Generar código (si es necesario)

```bash
flutter pub run build_runner build
```

## 📱 Ejecutar la App

### En Android

```bash
flutter run -d android
```

O especificar un dispositivo:

```bash
flutter devices              # Ver dispositivos disponibles
flutter run -d <device-id>
```

### En iOS

```bash
flutter run -d ios
```

## 🔧 Configuración

### ESP32 UUIDs

Los UUIDs del servicio y características están configurados en `lib/providers/ble_provider.dart`:

```dart
static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
static const String ledCharacteristicUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
```

**Debes reemplazarlos con los UUIDs reales de tu ESP32.**

### Permisos Android

Los permisos están definidos en `android/app/src/main/AndroidManifest.xml`:
- `BLUETOOTH` - Conexión Bluetooth
- `BLUETOOTH_ADMIN` - Escaneo
- `ACCESS_FINE_LOCATION` - Requerido para BLE (Android 6+)

## 📋 Estructura del Proyecto

```
app_android/
├── lib/
│   ├── main.dart                 ← Punto de entrada
│   ├── providers/
│   │   └── ble_provider.dart    ← Lógica de Bluetooth
│   └── screens/
│       ├── home_screen.dart      ← Pantalla principal
│       └── scan_screen.dart      ← Escaneo de dispositivos
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   ← Permisos
├── pubspec.yaml                  ← Dependencias
└── README.md
```

## 📚 Dependencias Principales

| Librería | Versión | Uso |
|----------|---------|-----|
| `flutter_blue_plus` | ^1.31.3 | Bluetooth BLE |
| `provider` | ^6.4.0 | State Management |
| `permission_handler` | ^11.4.4 | Permisos |
| `go_router` | ^13.0.0 | Navegación |

## 🐛 Troubleshooting

### "No BLE devices found"
- Verifica que la ESP32 esté en modo de anuncio BLE
- Revisa que el teléfono tiene Bluetooth habilitado
- En Android, asegúrate de que la localización está activada (requerida para BLE)

### "Connection failed"
- Verifica los UUIDs en `ble_provider.dart`
- Comprueba que la ESP32 tiene el servicio BLE configurado correctamente

### "Permission denied"
- En Android 6+, debes otorgar permisos de localización en tiempo de ejecución
- La app debería solicitar los permisos automáticamente

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## 📖 Próximos Pasos

1. **Fase 1**: Conectar a ESP32 y encender/apagar LED ✓ (este código)
2. **Fase 2**: Agregar temporizador
3. **Fase 3**: Ciclos ON/OFF configurables
4. **Fase 4**: Historial de eventos

## 🔗 Referencias

- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
- [Provider](https://pub.dev/packages/provider)
- [Flutter Documentation](https://flutter.dev/docs)
- [Android BLE Guide](https://developer.android.com/guide/topics/connectivity/bluetooth-le)
