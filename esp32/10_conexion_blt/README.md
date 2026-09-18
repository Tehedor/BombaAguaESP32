# Fase 1: Servidor BLE - ESP32

Servidor Bluetooth BLE que controla un LED vía una app móvil.

## Características

- ✅ Servidor BLE completo
- ✅ Servicio custom con UUID
- ✅ Característica para leer/escribir estado del LED
- ✅ Responde a conexiones y lecturas/escrituras

## Compilación

### Compilar

```bash
make compilef01
```

O manualmente:

```bash
docker-compose -f ../docker-compose.yml run --rm -w /workspace/esp32/10_conexion_blt esp-idf idf.py build
```

### Cargar en ESP32

```bash
make uploadf01 PORT=/dev/ttyUSB0
```

### Monitor Serial

```bash
make monitorf01
```

## UUIDs (IMPORTANTE)

El código usa estos UUIDs (deben coincidir con la app Flutter):

```
Servicio:        4fafc201-1fb5-459e-8fcc-c5c9c331914b
Característica:  beb5483e-36e1-4688-b7f5-ea07361b26a8
```

**Si usas otros UUIDs en la app Flutter**, actualiza los valores en `main.c`.

## Salida Esperada

```
[BOOT] Partition table:
...
I (xxx) BLE_FASE1: === Fase 1: Servidor BLE ===
I (xxx) BLE_FASE1: LED en GPIO25 - Control vía BLE
I (xxx) BLE_FASE1: Setup completado. BLE inicializado.
I (xxx) BLE_FASE1: GAP: Advertising started
I (xxx) BLE_FASE1: GATTS: Servicio iniciado
```

## Operación

1. **Compilar y cargar** el firmware
2. **Abrir la app Flutter** en Android
3. **Escanear** → Debería ver "BombaESP"
4. **Conectar** → Se conecta al ESP32
5. **Controlar LED** → Toca el botón para encender/apagar

## Troubleshooting

| Problema | Solución |
|----------|----------|
| No aparece en escaneo | Verifica que está compilado y cargado |
| "Connection refused" | Reset ESP32 (botón EN) |
| LED no responde | Verifica que GPIO25 está libre |
| Error de UUID | Asegúrate que coinciden con la app |

## Próximos Pasos

- Fase 2: Agregar temporizador BLE
- Fase 3: Ciclos ON/OFF
- Fase 4: Conectar bomba real
