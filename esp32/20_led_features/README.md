# Fase 11: Servidor BLE con PIN Seguro - ESP32

Servidor Bluetooth BLE mejorado con validación de PIN a nivel del firmware. Solo acepta comandos autenticados.

## Características

- ✅ Servidor BLE completo
- ✅ Validación de PIN en el firmware (máxima seguridad)
- ✅ Servicio custom con UUID
- ✅ Característica para leer/escribir estado del LED
- ✅ Rechazo de comandos sin PIN válido
- ✅ Contador de intentos fallidos

## Protocolo de Seguridad

Los comandos **DEBEN incluir el PIN** en los primeros 4 bytes:

```
Byte 0-3: PIN (como string "1357")
Byte 4:   Comando (0 = LED OFF, 1 = LED ON)
```

**Ejemplo:**
- Para encender: `[0x31, 0x33, 0x35, 0x37, 0x01]` → "1357" + ON
- Para apagar:  `[0x31, 0x33, 0x35, 0x37, 0x00]` → "1357" + OFF

## Compilación

```bash
make compilef01  # Desde raíz (busca automáticamente)
```

O manualmente:

```bash
docker-compose -f ../docker-compose.yml run --rm -w /workspace/esp32/11_conexion_blt_segura esp-idf idf.py build
```

## Cargar en ESP32

```bash
make uploadf01 PORT=/dev/ttyUSB0
```

## Monitor Serial

```bash
make monitorf01
```

## Configuración del PIN

Edita `/home/tehe/Work/bombaESP/esp32/11_conexion_blt_segura/main/ble_config.h`:

```c
#define BLE_PIN "1357"  // Cambiar aquí
```

Luego recompila y recarga el firmware.

## Salida Esperada

```
I (xxx) BLE_FASE11: === Phase 1: BLE Server ===
I (xxx) BLE_FASE11: ✓ GATTS app registered
I (xxx) BLE_FASE11: ✓ Service created (handle=40)
I (xxx) BLE_FASE11: ✓ Characteristic added (handle=42)
I (xxx) BLE_FASE11: ✓ Service started, starting advertising
I (xxx) BLE_FASE11: ✓ Advertising started - BombaESP visible
I (xxx) BLE_FASE11: 🔐 BLE PIN: 1357 (required for pairing)
```

## Seguridad

| Escenario | Resultado |
|-----------|-----------|
| Conectar sin PIN | Conexión aceptada, pero comandos rechazados |
| Enviar comando sin PIN | ❌ Error: `ESP_GATT_INSUF_AUTHENTICATION` |
| Enviar comando con PIN incorrecto | ❌ Error: `ESP_GATT_INSUF_AUTHENTICATION` |
| Enviar comando con PIN correcto | ✅ LED responde, contador de fallos reset |

## Diferencias vs Fase 10

| Aspecto | Fase 10 | Fase 11 |
|--------|---------|---------|
| Validación de PIN | App Flutter | **Firmware ESP32** ✓ |
| Sin PIN, ¿qué pasa? | Conecta y controla | ❌ Rechaza comandos |
| Seguridad | Media | **Alta** ✓ |
| Compatibilidad | Cualquier cliente BLE | Solo con PIN correcto |

## Próximos Pasos

- **Fase 2**: Agregar temporizador
- **Fase 3**: Ciclos ON/OFF
- **Fase 4**: Conectar bomba real (usar esta seguridad)

## Troubleshooting

| Problema | Solución |
|----------|----------|
| LED no responde | Verifica que el PIN sea correcto (4 bytes + comando = 5 bytes) |
| Conexión rechazada | Reset ESP32 (botón EN) |
| "INSUF_AUTHENTICATION" | PIN incorrecto en el comando |
| GPIO25 en uso | Revisa que no esté ocupado por otra función |

