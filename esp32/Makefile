# ESP32 Makefile - BombaESP Project
# Docker + ESP-IDF
# Uso: make compilef00 / make uploadf00 / make monitorf00

.PHONY: compilef00 uploadf00 monitorf00 compilef10 uploadf10 monitorf10 compilef11 uploadf11 monitorf11 compilef20 uploadf20 monitorf20 cleanf20 compilef30 uploadf30 monitorf30 cleanf30 compilef31 uploadf31 monitorf31 cleanf31 ports clean help

# Variables
PORT ?= /dev/ttyUSB0
BAUD ?= 921600
DC := docker-compose

# Directorios de fases
F00_DIR := 00_led
F01_DIR := 10_conexion_blt
F11_DIR := 11_conexion_blt_segura
F20_DIR := 20_led_features
F30_DIR := 30_rele_features
F31_DIR := 31_rele_deploy

# ============================================================================
# FASE 0 - Parpadeo LED
# ============================================================================

compilef00:
	@echo "🔨 Compilando Fase 0 (LED)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf idf.py build

uploadf00:
	@echo "📤 Cargando Fase 0 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf00:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F00_DIR) esp-idf idf.py -p $(PORT) monitor

# ============================================================================
# FASE 1 - Conexión BLE
# ============================================================================

compilef10:
	@echo "🔨 Compilando Fase 10 (BLE)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf idf.py build

uploadf10:
	@echo "📤 Cargando Fase 10 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf10:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F01_DIR) esp-idf idf.py -p $(PORT) monitor

# ============================================================================
# FASE 11 - Conexión BLE con PIN Seguro
# ============================================================================

compilef11:
	@echo "🔨 Compilando Fase 11 (BLE + PIN)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F11_DIR) esp-idf idf.py build

uploadf11:
	@echo "📤 Cargando Fase 11 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F11_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf11:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F11_DIR) esp-idf idf.py -p $(PORT) monitor

# ============================================================================
# FASE 20 - LED Features (Timer + Ciclos + Seguridad)
# ============================================================================

compilef20:
	@echo "🔨 Compilando Fase 20 (LED Features)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F20_DIR) esp-idf idf.py build

uploadf20:
	@echo "📤 Cargando Fase 20 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F20_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf20:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F20_DIR) esp-idf idf.py -p $(PORT) monitor

cleanf20:
	@echo "🧹 Limpiando Fase 20 completamente..."
	sudo rm -rf /home/tehe/Work/bombaESP/esp32/20_led_features/build
	@echo "✓ Fase 20 limpiada"

# ============================================================================
# FASE 30 - Relé + LED (Timer + Ciclos)
# ============================================================================

compilef30:
	@echo "🔨 Compilando Fase 30 (Relé + LED)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F30_DIR) esp-idf idf.py build

uploadf30:
	@echo "📤 Cargando Fase 30 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F30_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf30:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F30_DIR) esp-idf idf.py -p $(PORT) monitor

cleanf30:
	@echo "🧹 Limpiando Fase 30 completamente..."
	sudo rm -rf /home/tehe/Work/bombaESP/esp32/30_rele_features/build
	@echo "✓ Fase 30 limpiada"

# ============================================================================
# FASE 31 - Relé Deploy (Sin LED de testeo)
# ============================================================================

compilef31:
	@echo "🔨 Compilando Fase 31 (Relé Deploy)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F31_DIR) esp-idf idf.py build

uploadf31:
	@echo "📤 Cargando Fase 31 en $(PORT)..."
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F31_DIR) esp-idf idf.py -p $(PORT) -b $(BAUD) flash

monitorf31:
	@echo "📡 Monitor Serial en $(PORT) (115200 baud)"
	$(DC) -f ../docker-compose.yml run --rm -w /workspace/esp32/$(F31_DIR) esp-idf idf.py -p $(PORT) monitor

cleanf31:
	@echo "🧹 Limpiando Fase 31 completamente..."
	sudo rm -rf /home/tehe/Work/bombaESP/esp32/31_rele_deploy/build
	@echo "✓ Fase 31 limpiada"

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
	@echo "FASE 10 (BLE):"
	@echo "  make compilef10         🔨 Compilar"
	@echo "  make uploadf10          📤 Cargar"
	@echo "  make monitorf10         📡 Monitor"
	@echo ""
	@echo "FASE 11 (BLE + PIN Seguro):"
	@echo "  make compilef11         🔨 Compilar"
	@echo "  make uploadf11          📤 Cargar"
	@echo "  make monitorf11         📡 Monitor"
	@echo ""
	@echo "FASE 20 (LED - Timer + Ciclos):"
	@echo "  make compilef20         🔨 Compilar"
	@echo "  make uploadf20          📤 Cargar"
	@echo "  make monitorf20         📡 Monitor"
	@echo "  make cleanf20           🧹 Limpiar build (rm -rf)"
	@echo ""
	@echo "FASE 30 (Relé + LED - Timer + Ciclos):"
	@echo "  make compilef30         🔨 Compilar"
	@echo "  make uploadf30          📤 Cargar"
	@echo "  make monitorf30         📡 Monitor"
	@echo "  make cleanf30           🧹 Limpiar build (rm -rf)"
	@echo ""
	@echo "FASE 31 (Relé Deploy - Sin LED):"
	@echo "  make compilef31         🔨 Compilar"
	@echo "  make uploadf31          📤 Cargar"
	@echo "  make monitorf31         📡 Monitor"
	@echo "  make cleanf31           🧹 Limpiar build (rm -rf)"
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
