# Quick Start - BombaESP (Docker + ESP-IDF)

## ⚡ 3 Pasos

```bash
cd /home/tehe/Work/bombaESP

# 1. Compilar Fase 0
make compilef00

# 2. Detectar puerto USB
make ports

# 3. Cargar + Monitor
make uploadf00 PORT=/dev/ttyUSB0
make monitorf00
```

## ✅ Verificación

Deberías ver en el monitor serial:

```
=== Fase 0: Parpadeo LED ===
LED en GPIO25 - Parpadea cada 3 segundos
Setup completado.

LED: ON
LED: OFF
LED: ON
...
```

Y el LED parpadear cada 3 segundos.

## 📦 Requisitos

- **Docker** instalado (se asume preinstalado)
- **ESP32** conectada por USB
- **Makefile** (incluido en el proyecto)

## 📚 Todos los Comandos

```bash
make help              # Muestra todos los comandos
make compilef00        # Compila Fase 0
make uploadf00         # Carga en ESP32
make monitorf00        # Monitor serial
make ports             # Lista puertos USB
make clean             # Limpia compilaciones
```

## 🔄 Flujo Típico

1. **Editar código**: `esp32/00_led/main/main.c`
2. **Compilar**: `make compilef00`
3. **Cargar**: `make uploadf00`
4. **Probar**: `make monitorf00`

## 📖 Más Información

- `Proyecto.md` — Especificaciones técnicas
- `DOCKER.md` — Detalles de Docker
- `Claude.md` — Arquitectura del proyecto
