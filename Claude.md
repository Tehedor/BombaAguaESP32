# BombaESP - Arquitectura y Flujo

## 📋 Especificaciones
Ver **Proyecto.md** para detalles técnicos, componentes y fases.

## 🏗️ División del Proyecto

### ESP32 (Firmware)
- **Lenguaje**: C puro
- **Framework**: ESP-IDF v5.2
- **Build**: CMake
- **Herramientas**: Docker (todo automatizado)
- **Ubicación**: `esp32/`

### App Móvil (Flutter)
- **Framework**: Flutter + Dart
- **Ubicación**: `app_android/`
- **Estado**: Fase 1 lista (código + dependencias)
- **Librerías**: flutter_blue_plus, provider, permission_handler
- **Características**: Escaneo BLE, conexión, control LED

## ⚡ Flujo Rápido (3 comandos)

```bash
make compilef00          # Compila (Docker automático)
make ports               # Detecta puerto USB
make uploadf00           # Carga firmware
make monitorf00          # Ve salida en tiempo real
```

## 📋 Fases

### Fase 0 ✓ (Actual)
- LED en GPIO25 parpadea cada 3 segundos
- Validación básica del hardware
- `make compilef00` / `uploadf00` / `monitorf00`

### Fase 1 (Próximo)
- Botón en GPIO27 controla LED
- Bluetooth BLE básico

### Fase 2 (Futuro)
- Temporizador desde app móvil
- Ciclos ON/OFF configurables

### Fase 3 (Futuro)
- Bomba real 12V con protecciones

## 🐳 Docker Incluido
- No requiere instalación local de ESP-IDF
- `espressif/idf:v5.2` automatizado en docker-compose.yml
- Todo corre en contenedor

## 📖 Documentación
- `Proyecto.md` — Especificaciones técnicas
- `DOCKER.md` — Detalles de Docker
- `QUICKSTART.md` — 3 pasos para empezar