# BombaESP - Makefile Principal
# Docker + ESP-IDF (sin instalación local necesaria)

.PHONY: help compilef00 uploadf00 monitorf00 compilef10 uploadf10 monitorf10 compilef11 uploadf11 monitorf11 compilef20 uploadf20 monitorf20 cleanf20 compilef30 uploadf30 monitorf30 cleanf30 compilef31 uploadf31 monitorf31 cleanf31 f10_run f11_run f20_run f30_run f30_build f30_install f30_share ports clean

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
	@echo "FASE 10 (BLE - Conexión Bluetooth):"
	@echo "  make compilef10         🔨 Compilar código"
	@echo "  make uploadf10          📤 Cargar en ESP32"
	@echo "  make monitorf10         📡 Monitor serial"
	@echo "  make f10_run            📱 Ejecutar app Flutter"
	@echo ""
	@echo "FASE 11 (BLE + PIN Seguro):"
	@echo "  make compilef11         🔨 Compilar código"
	@echo "  make uploadf11          📤 Cargar en ESP32"
	@echo "  make monitorf11         📡 Monitor serial"
	@echo "  make f11_run            📱 Ejecutar app Flutter"
	@echo ""
	@echo "FASE 20 (LED Features - Timer + Ciclos):"
	@echo "  make compilef20         🔨 Compilar código"
	@echo "  make uploadf20          📤 Cargar en ESP32"
	@echo "  make monitorf20         📡 Monitor serial"
	@echo "  make cleanf20           🧹 Limpiar build (rm -rf)"
	@echo "  make f20_run            📱 Ejecutar app Flutter"
	@echo ""
	@echo "FASE 30 (Relé + LED - Timer + Ciclos):"
	@echo "  make compilef30         🔨 Compilar código ESP32"
	@echo "  make uploadf30          📤 Cargar en ESP32"
	@echo "  make monitorf30         📡 Monitor serial"
	@echo "  make cleanf30           🧹 Limpiar build (rm -rf)"
	@echo "  make f30_run            📱 Ejecutar app Flutter"
	@echo "  make f30_build          📦 Compilar APK para instalar"
	@echo "  make f30_install        📱 Instalar APK en móvil"
	@echo "  make f30_share          📤 Preparar APK para WhatsApp (~/bomba_fase30.apk)"
	@echo ""
	@echo "FASE 31 (Relé Deploy - Sin LED):"
	@echo "  make compilef31         🔨 Compilar código ESP32"
	@echo "  make uploadf31          📤 Cargar en ESP32"
	@echo "  make monitorf31         📡 Monitor serial"
	@echo "  make cleanf31           🧹 Limpiar build (rm -rf)"
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

compilef10:
	@$(MAKE) -C esp32 compilef10 PORT=$(PORT) BAUD=$(BAUD)

uploadf10:
	@$(MAKE) -C esp32 uploadf10 PORT=$(PORT) BAUD=$(BAUD)

monitorf10:
	@$(MAKE) -C esp32 monitorf10 PORT=$(PORT) BAUD=$(BAUD)

compilef11:
	@$(MAKE) -C esp32 compilef11 PORT=$(PORT) BAUD=$(BAUD)

uploadf11:
	@$(MAKE) -C esp32 uploadf11 PORT=$(PORT) BAUD=$(BAUD)

monitorf11:
	@$(MAKE) -C esp32 monitorf11 PORT=$(PORT) BAUD=$(BAUD)

compilef20:
	@$(MAKE) -C esp32 compilef20 PORT=$(PORT) BAUD=$(BAUD)

uploadf20:
	@$(MAKE) -C esp32 uploadf20 PORT=$(PORT) BAUD=$(BAUD)

monitorf20:
	@$(MAKE) -C esp32 monitorf20 PORT=$(PORT) BAUD=$(BAUD)

cleanf20:
	@$(MAKE) -C esp32 cleanf20 PORT=$(PORT) BAUD=$(BAUD)

compilef30:
	@$(MAKE) -C esp32 compilef30 PORT=$(PORT) BAUD=$(BAUD)

uploadf30:
	@$(MAKE) -C esp32 uploadf30 PORT=$(PORT) BAUD=$(BAUD)

monitorf30:
	@$(MAKE) -C esp32 monitorf30 PORT=$(PORT) BAUD=$(BAUD)

cleanf30:
	@$(MAKE) -C esp32 cleanf30 PORT=$(PORT) BAUD=$(BAUD)

compilef31:
	@$(MAKE) -C esp32 compilef31 PORT=$(PORT) BAUD=$(BAUD)

uploadf31:
	@$(MAKE) -C esp32 uploadf31 PORT=$(PORT) BAUD=$(BAUD)

monitorf31:
	@$(MAKE) -C esp32 monitorf31 PORT=$(PORT) BAUD=$(BAUD)

cleanf31:
	@$(MAKE) -C esp32 cleanf31 PORT=$(PORT) BAUD=$(BAUD)

f10_run:
	@$(MAKE) -C app_android f10_run

f11_run:
	@$(MAKE) -C app_android f11_run

f20_run:
	@$(MAKE) -C app_android f20_run

f30_run:
	@$(MAKE) -C app_android f30_run

f30_build:
	@echo "🔨 Building APK Fase 30..."
	@$(MAKE) -C app_android f30_build
	@echo ""
	@echo "✅ APK compilado exitosamente"
	@echo "📱 Ubicación: app_android/30_rele_mode/build/app/outputs/flutter-apk/app-release.apk"
	@echo ""
	@echo "Para compartir por WhatsApp:"
	@echo "  cp app_android/30_rele_mode/build/app/outputs/flutter-apk/app-release.apk ~/bomba_fase30.apk"
	@echo ""

f30_install:
	@echo "📱 Instalando APK en dispositivo conectado..."
	@$(MAKE) -C app_android f30_build > /dev/null 2>&1
	cd app_android/30_rele_mode && flutter install

f30_share:
	@echo "📤 Preparando APK para compartir..."
	@if [ ! -f app_android/30_rele_mode/build/app/outputs/flutter-apk/app-release.apk ]; then \
		echo "❌ APK no encontrado. Compilando..."; \
		$(MAKE) f30_build > /dev/null 2>&1; \
	fi
	@cp app_android/30_rele_mode/build/app/outputs/flutter-apk/app-release.apk ~/bomba_fase30.apk
	@echo "✅ APK listo para compartir"
	@echo "📍 Ubicación: ~/bomba_fase30.apk"
	@echo "📱 Descarga link: file://$(HOME)/bomba_fase30.apk"

ports:
	@$(MAKE) -C esp32 ports PORT=$(PORT) BAUD=$(BAUD)

clean:
	@$(MAKE) -C esp32 clean PORT=$(PORT) BAUD=$(BAUD)

.DEFAULT_GOAL := help
