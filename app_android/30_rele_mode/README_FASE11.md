# App Flutter - Fase 11 (BLE Seguro con PIN)

Esta es la versión de la app Flutter **compatible con Fase 11** del firmware ESP32.

## Diferencias vs app_android (Fase 10)

| Aspecto | app_android (F10) | app_android_fase11 (F11) |
|--------|-------------------|--------------------------|
| PIN validado en | App Flutter | **Firmware ESP32** ✓ |
| Protocolo | 1 byte (comando) | **5 bytes** (4 PIN + 1 cmd) |
| Si PIN es incorrecto | Rechazado en app | **Rechazado por firmware** ✓ |
| Seguridad | Media | **Alta** ✓ |

## Instalación

```bash
cd /home/tehe/Work/bombaESP/app_android_fase11

# Limpiar e instalar dependencias
flutter clean
flutter pub get

# Ejecutar en el dispositivo
flutter run
```

## Cambiar el PIN

Edita `lib/providers/ble_provider.dart`:

```dart
// Línea ~28
static const String BLE_PIN = '1357';  // ← Cambiar aquí
```

Luego vuelve a ejecutar `flutter run`.

## Protocolo de Comunicación (Fase 11)

La app envía **5 bytes** a la característica BLE:

```
[Byte 0] [Byte 1] [Byte 2] [Byte 3] [Byte 4]
  0x31     0x33     0x35     0x37     0x01
   '1'      '3'      '5'      '7'     (1=ON, 0=OFF)
```

### Ejemplo en código Dart:
```dart
final List<int> pinBytes = "1357".codeUnits;  // [0x31, 0x33, 0x35, 0x37]
final List<int> command = [...pinBytes, 1];   // [0x31, 0x33, 0x35, 0x37, 0x01]
await characteristic.write(command);
```

## Compatibilidad

### ✅ Funciona con:
- Fase 11 ESP32 (`11_conexion_blt_segura`)

### ❌ NO funciona con:
- Fase 10 ESP32 (`10_conexion_blt`)
  - Razón: Fase 10 espera 1 byte, Fase 11 espera 5 bytes

### Qué hacer:
- Si tienes Fase 10 → Usa `app_android`
- Si tienes Fase 11 → Usa `app_android_fase11`

## Pantallas

1. **HomeScreen** - Muestra estado conexión y controles LED
   - Botón grande circular (ON/OFF toggle)
   - Botones individuales (Encender/Apagar)
   - Botón de desconectar

2. **ScanScreen** - Escanea dispositivos BLE
   - Lista de dispositivos cercanos
   - Pide PIN antes de conectar
   - Conecta a dispositivo seleccionado

## Troubleshooting

| Problema | Solución |
|----------|----------|
| "Error al conectar" | Verifica que Fase 11 esté cargada en ESP32 |
| LED no responde | PIN incorrecto - edita `ble_provider.dart` |
| "INSUF_AUTHENTICATION" en logs | PIN enviado es incorrecto (verifica `.codeUnits`) |
| "Connection refused" | Reset ESP32 (presiona botón EN) |
| App no detecta dispositivo | Verifica Bluetooth está habilitado en el móvil |

## Logs Esperados

### Conexión exitosa:
```
I/flutter: ✓ GATTS app registered
I/flutter: 💡 Writing LED state: ON with PIN
I/flutter: ✅ LED state changed successfully (PIN validated by firmware)
```

### PIN incorrecto:
```
I/flutter: ❌ Error enviando comando: PlatformException...
I/flutter: 🚨 PIN incorrecto o comando rechazado por firmware
```

## Notas de Desarrollo

- La app **NO valida el PIN localmente** (validación solo en firmware)
- Si cambias el PIN en el firmware, DEBES cambiar también en la app
- El PIN se envía como **ASCII bytes** (texto, no hexadecimal)
- 5 bytes mínimos requeridos (4 PIN + 1 comando)

## Próximos Pasos

- Fase 4: Conectar bomba real usando esta seguridad
- Agregar EEPROM para persistencia de PIN
- Implementar cambio de PIN desde la app
