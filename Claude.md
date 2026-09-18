# BombaESP - Control remoto de bomba con ESP32 y Bluetooth BLE

## Resumen del Proyecto

Sistema de control remoto para una bomba de agua **12V 6A** usando **ESP32** comunicada vía **Bluetooth BLE** desde una app móvil.

### Arquitectura actual

- **Hardware**: ESP32-WROOM-32, relé de 2 canales (SRD-05VDC-SL-C), botón físico, LED indicador
- **Comunicación**: Bluetooth BLE (proximidad)
- **Estado**: Fase inicial - validación con LED, sin bomba conectada aún
- **Estructura**:
  - `esp32/` — firmware con fases progresivas
  - `app_android/` — aplicación móvil (por desarrollar)

## Especificaciones Técnicas

### Componentes disponibles

- ESP32-WROOM-32 en placa de expansión
- Módulo relé 2 canales: SRD-05VDC-SL-C (10A 30VDC / 10A 250VAC)
- LEDs, botones, resistencias (kit estándar)
- Fuente de alimentación y bomba (por conectar)

### Diseño de pines (fase actual)

| Componente | GPIO | Detalles |
|-----------|------|---------|
| Relé (IN1) | GPIO26 | Control de conmutación |
| Botón | GPIO27 | Entrada con INPUT_PULLUP |
| LED indicador | GPIO25 | Resistencia 220-330Ω |

### Cableado

**Relé:**
```
ESP32 5V/VIN → VCC relé
ESP32 GND    → GND relé
ESP32 GPIO26 → IN1 relé
```

**Botón:**
```
Un lado → GPIO27
Otro   → GND
```

**LED simulador (a través del relé):**
```
3V3/5V → resistencia → COM del relé
NO relé → pata larga LED
Pata corta LED → GND
```

## Fases de Desarrollo

### Fase 0 ✓ (En curso)
- Encender/apagar LED cada 3 segundos (validación básica)
- **Stack**: C puro + ESP-IDF + esptool
- Botón físico controla relé y LED (próximo)

### Fase 1 ✓ (En curso)
- **ESP32**: Firmware BLE básico (por hacer en `esp32/10_conexion_blt/`)
- **App**: Flutter lista ✓ (`app_android/`)
  - Escaneo y conexión BLE
  - Control encender/apagar LED
  - Interfaz Material Design 3
  - State management con Provider

### Fase 2
- Temporizador desde app móvil
- Ciclos ON/OFF configurables

### Fase 3
- Integración con bomba real (12V, fusible, protecciones)
- Validación de márgenes de seguridad

## Frameworks Recomendados para App Móvil

| Framework | Lenguaje | Multiplataforma | BLE | Recomendación |
|-----------|----------|-----------------|-----|---|
| **Flutter** ⭐ | Dart | ✅ iOS + Android | Excelente (`flutter_blue_plus`) | **RECOMENDADO** — mejor para IoT/BLE, performance nativa, APK ligero |
| React Native | JavaScript | ✅ iOS + Android | Bueno (`react-native-ble-plx`) | Alternativa si prefieres JS, APK más pesado |
| Kotlin nativo | Kotlin | ❌ Android only | Excelente (Android API) | Si solo quieres Android, máxima performance |
| Java nativo | Java | ❌ Android only | Bueno | Descartado — más verboso que Kotlin |

**Conclusión:** Usa **Flutter** para este proyecto. Ideal para IoT/BLE, futuro-proof (iOS), y rápido de desarrollar.

## ⚠️ Advertencias de Seguridad

- Relé especifica 10A 30VDC, pero bomba 12V 6A puede tener picos de arranque superiores
- Antes de conectar bomba real:
  - Revisar margen de seguridad del relé
  - Instalar fusible adecuado
  - Protección contra picos (diodo de libre circulación)
  - Validar alimentación 12V con capacidad suficiente