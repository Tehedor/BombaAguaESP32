# Setup Flutter - Quick Start

## 1️⃣ Instalar Flutter (Primera vez)

```bash
# Descargar Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:~/flutter/bin"

# Verificar instalación
flutter doctor
```

## 2️⃣ Obtener dependencias

```bash
cd app_android
flutter pub get
```

## 3️⃣ Ejecutar la app

### En Android (Emulador o dispositivo físico)

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar
flutter run

# O especificar dispositivo
flutter run -d emulator-5554
```

### En iOS (Mac solo)

```bash
flutter run -d ios
```

## 🔧 Configuración Importante

### UUIDs de ESP32

**Antes de compilar**, edita `lib/providers/ble_provider.dart` y reemplaza:

```dart
static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
static const String ledCharacteristicUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
```

Con los UUIDs reales de tu ESP32 Fase 1.

### Permisos Android

Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`. La app solicitará:
- ✓ Acceso a Bluetooth
- ✓ Acceso a localización (requerido para escaneo BLE)

## 📱 Estructura de la App

1. **HomeScreen** — Pantalla principal (conexión + control LED)
2. **ScanScreen** — Escaneo de dispositivos disponibles
3. **BLEProvider** — Lógica de comunicación Bluetooth

## 🚀 Flujo de Uso

1. **Iniciar app** → HomeScreen (no conectado)
2. **Escanear** → ScanScreen (busca dispositivos BLE)
3. **Conectar** → Selecciona "ESP32" de la lista
4. **Controlar** → Enciende/apaga LED desde HomeScreen

## 🐛 Errores Comunes

### "No devices found"
- ¿ESP32 transmitiendo BLE? Verifica Fase 0 (LED parpadeando)
- ¿Bluetooth habilitado en teléfono?
- ¿Localización ON? (Requerido en Android)

### "Connection failed"
- Verifica UUIDs en `ble_provider.dart`
- Comprueba que el ESP32 está cerca

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Librerías Utilizadas

- `flutter_blue_plus` — Bluetooth BLE
- `provider` — State management
- `permission_handler` — Permisos
- `go_router` — Navegación (futuro)

## ✅ Siguiente Paso

Una vez funcione:
1. Compila APK: `flutter build apk`
2. O prueba en dispositivo: `flutter run --release`

## 🔗 Documentación

- [Flutter Docs](https://flutter.dev/docs)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
