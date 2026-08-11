# BombaESP - Makefile Principal
# Docker + ESP-IDF (sin instalación local necesaria)

.PHONY: help compilef00 uploadf00 monitorf00 compilef01 uploadf01 monitorf01 ports clean

# Variables (pueden sobrescribirse)
PORT ?= /dev/ttyUSB0
BAUD ?= 921600

help:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║         BombaESP - Control de bomba con ESP32 + BLE        ║"
	@echo "║              Docker + ESP-IDF (lista para usar)            ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "FASE 0 (LED - Validación básica):"
	@echo "  make compilef00         🔨 Compilar código"
	@echo "  make uploadf00          📤 Cargar en ESP32"
	@echo "  make monitorf00         📡 Monitor serial (115200 baud)"
	@echo ""
	@echo "FASE 1 (BLE - Conexión Bluetooth):"
	@echo "  make compilef01         🔨 Compilar código"
	@echo "  make uploadf01          📤 Cargar en ESP32"
	@echo "  make monitorf01         📡 Monitor serial"
	@echo ""
	@echo "UTILIDADES:"
	@echo "  make ports              🔌 Detectar puertos USB"
	@echo "  make clean              🧹 Limpiar compilaciones"
	@echo ""
	@echo "VARIABLES (defecto):"
	@echo "  PORT=$(PORT)            Puerto USB"
	@echo "  BAUD=$(BAUD)            Velocidad en baud"
	@echo ""
	@echo "EJEMPLOS:"
	@echo "  make compilef00"
	@echo "  make uploadf00 PORT=/dev/ttyUSB0"
	@echo "  make monitorf00"
	@echo "  make ports"
	@echo ""

# ============================================================================
# DELEGACIÓN A esp32/Makefile
# ============================================================================

compilef00:
	@$(MAKE) -C esp32 compilef00 PORT=$(PORT) BAUD=$(BAUD)

uploadf00:
	@$(MAKE) -C esp32 uploadf00 PORT=$(PORT) BAUD=$(BAUD)

monitorf00:
	@$(MAKE) -C esp32 monitorf00 PORT=$(PORT) BAUD=$(BAUD)

compilef01:
	@$(MAKE) -C esp32 compilef01 PORT=$(PORT) BAUD=$(BAUD)

uploadf01:
	@$(MAKE) -C esp32 uploadf01 PORT=$(PORT) BAUD=$(BAUD)

monitorf01:
	@$(MAKE) -C esp32 monitorf01 PORT=$(PORT) BAUD=$(BAUD)

ports:
	@$(MAKE) -C esp32 ports PORT=$(PORT) BAUD=$(BAUD)

clean:
	@$(MAKE) -C esp32 clean PORT=$(PORT) BAUD=$(BAUD)

.DEFAULT_GOAL := help
