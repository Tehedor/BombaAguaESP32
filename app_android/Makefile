# Flutter App Makefile - BombaESP
# Estructura: 10_app (Fase 10) y 11_app (Fase 11)

.PHONY: f10_run f10_clean f10_build f11_run f11_clean f11_build f20_run f20_clean f20_build f30_run f30_clean f30_build help

help:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║       BombaESP - Flutter App (Docker + Flutter)            ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "FASE 10 (BLE Básico):"
	@echo "  make f10_run            📱 Ejecutar app"
	@echo "  make f10_build          🔨 Build APK"
	@echo "  make f10_clean          🧹 Limpiar"
	@echo ""
	@echo "FASE 11 (BLE + PIN Seguro):"
	@echo "  make f11_run            📱 Ejecutar app"
	@echo "  make f11_build          🔨 Build APK"
	@echo "  make f11_clean          🧹 Limpiar"
	@echo ""
	@echo "FASE 20 (LED Features - Timer + Ciclos):"
	@echo "  make f20_run            📱 Ejecutar app"
	@echo "  make f20_build          🔨 Build APK"
	@echo "  make f20_clean          🧹 Limpiar"
	@echo ""
	@echo "FASE 30 (Relé + LED - Timer + Ciclos):"
	@echo "  make f30_run            📱 Ejecutar app"
	@echo "  make f30_build          🔨 Build APK"
	@echo "  make f30_clean          🧹 Limpiar"
	@echo ""
	@echo "NOTAS:"
	@echo "  - Asegúrate de estar en el directorio correcto"
	@echo "  - El dispositivo debe estar conectado vía USB"
	@echo "  - flutter debe estar en el PATH"
	@echo ""

# ============================================================================
# FASE 10 (BLE Básico)
# ============================================================================

f10_run:
	@echo "📱 Ejecutando Fase 10 (BLE)..."
	cd 10_app && flutter run

f10_build:
	@echo "🔨 Building APK Fase 10..."
	cd 10_app && flutter build apk --release

f10_clean:
	@echo "🧹 Limpiando Fase 10..."
	cd 10_app && flutter clean

# ============================================================================
# FASE 11 (BLE + PIN Seguro)
# ============================================================================

f11_run:
	@echo "📱 Ejecutando Fase 11 (BLE + PIN)..."
	cd 11_app && flutter run

f11_build:
	@echo "🔨 Building APK Fase 11..."
	cd 11_app && flutter build apk --release

f11_clean:
	@echo "🧹 Limpiando Fase 11..."
	cd 11_app && flutter clean

# ============================================================================
# FASE 20 (LED Features - Timer + Ciclos)
# ============================================================================

f20_run:
	@echo "📱 Ejecutando Fase 20 (LED Features)..."
	cd 20_app && flutter run

f20_build:
	@echo "🔨 Building APK Fase 20..."
	cd 20_app && flutter build apk --release

f20_clean:
	@echo "🧹 Limpiando Fase 20..."
	cd 20_app && flutter clean

# ============================================================================
# FASE 30 (Relé + LED - Timer + Ciclos)
# ============================================================================

f30_run:
	@echo "📱 Ejecutando Fase 30 (Relé + LED)..."
	cd 30_rele_mode && flutter run

f30_build:
	@echo "🔨 Building APK Fase 30..."
	cd 30_rele_mode && flutter build apk --release

f30_clean:
	@echo "🧹 Limpiando Fase 30..."
	cd 30_rele_mode && flutter clean

.DEFAULT_GOAL := help
