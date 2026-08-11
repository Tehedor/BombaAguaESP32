# ESP32 Makefile - BombaESP Project
# Docker + ESP-IDF
# Uso: make compilef00 / make uploadf00 / make monitorf00

.PHONY: compilef00 uploadf00 monitorf00 compilef01 uploadf01 monitorf01 ports clean help

# Variables
PORT ?= /dev/ttyUSB0
BAUD ?= 921600
DC := docker-compose

# Directorios de fases
F00_DIR := 00_led
F01_DIR := 10_conexion_blt

# ============================================================================
# FASE 0 - Parpadeo LED
# ============================================================================

compilef00:
	@echo "🔨 Compilando Fase 0 (LED)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf idf.py build

uploadf00:
	@echo "📤 Cargando Fase 0 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf esptool.py -p $(PORT) -b $(BAUD) flash

monitorf00:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf idf.py -p $(PORT) monitor

# ============================================================================
# FASE 1 - Conexión BLE
# ============================================================================

compilef01:
	@echo "🔨 Compilando Fase 1 (BLE)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf idf.py build

uploadf01:
	@echo "📤 Cargando Fase 1 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf esptool.py -p $(PORT) -b $(BAUD) flash

monitorf01:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf idf.py -p $(PORT) monitor

# ============================================================================
# Utilidades
# ============================================================================

ports:
	@echo "🔌 Puertos disponibles:"
	@$(DC) -f ../docker-compose.yml run --rm esp-idf bash -c "python3 -c \"import serial.tools.list_ports; [print(f'  ✓ {p.device}: {p.description}') for p in serial.tools.list_ports.comports()]\""

clean:
	@echo "🧹 Limpiando builds..."
	find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "✓ Limpieza completada"

help:
	@echo "ESP32 Makefile - BombaESP (Docker + ESP-IDF)"
	@echo ""
	@echo "FASE 0 (LED):"
	@echo "  make compilef00         🔨 Compilar"
	@echo "  make uploadf00          📤 Cargar en ESP32"
	@echo "  make monitorf00         📡 Monitor Serial"
	@echo ""
	@echo "FASE 1 (BLE):"
	@echo "  make compilef01         🔨 Compilar"
	@echo "  make uploadf01          📤 Cargar"
	@echo "  make monitorf01         📡 Monitor"
	@echo ""
	@echo "UTILIDADES:"
	@echo "  make ports              🔌 Listar puertos USB"
	@echo "  make clean              🧹 Limpiar compilaciones"
	@echo ""
	@echo "VARIABLES:"
	@echo "  PORT=/dev/ttyUSB0       Puerto (default: /dev/ttyUSB0)"
	@echo "  BAUD=921600             Velocidad (default: 921600)"
	@echo ""

.DEFAULT_GOAL := help
