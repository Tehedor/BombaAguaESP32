#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_bt_device.h"
#include "esp_bt_main.h"
#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_gatt_defs.h"
#include "driver/gpio.h"
#include "ble_config.h"

#define TAG "BLE_FASE31"
#define RELE_PIN GPIO_NUM_26
#define GATTS_APP_ID 0x55

#define MAX_TIMER_SECONDS 3600
#define MIN_CYCLE_SECONDS 1
#define HISTORY_SIZE 5

typedef enum {
    MODE_MANUAL = 0,
    MODE_TIMER = 1,
    MODE_CYCLES = 2
} operation_mode_t;

typedef struct {
    uint32_t timestamp;
    uint8_t mode;
    uint16_t param1;
    uint16_t param2;
} activation_record_t;

static uint8_t rele_state = 0;
static uint16_t gatts_if = ESP_GATT_IF_NONE;
static uint16_t service_handle = 0;
static uint16_t char_handle = 0;
static uint16_t cccd_handle = 0;
static uint16_t conn_id = 0;

static operation_mode_t current_mode = MODE_MANUAL;
static uint16_t timer_duration = 0;
static uint16_t cycle_on_time = 0;
static uint16_t cycle_off_time = 0;
static uint32_t operation_start_time = 0;
static uint32_t failed_attempts = 0;
static TaskHandle_t operation_task_handle = NULL;
static TaskHandle_t notification_task_handle = NULL;

static activation_record_t history[HISTORY_SIZE];
static uint8_t history_index = 0;

static uint8_t service_uuid_128[16] = {
    0x4b, 0x91, 0x31, 0xc3, 0xc9, 0xc5, 0xcc, 0x8f,
    0x9e, 0x45, 0xb5, 0x1f, 0x01, 0xc2, 0xaf, 0x4f
};

static uint8_t char_uuid_128[16] = {
    0xa8, 0x26, 0x1b, 0x36, 0x07, 0xea, 0xf5, 0xb7,
    0x88, 0x46, 0xe1, 0x36, 0x3e, 0x48, 0xb5, 0xbe
};

static esp_ble_adv_data_t adv_data = {
    .set_scan_rsp = false,
    .include_name = true,
    .include_txpower = true,
    .min_interval = 0x0020,
    .max_interval = 0x0040,
    .appearance = 0x00,
    .manufacturer_len = 0,
    .p_manufacturer_data = NULL,
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = 16,
    .p_service_uuid = service_uuid_128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

static esp_ble_adv_params_t adv_params = {
    .adv_int_min = 0x0020,
    .adv_int_max = 0x0040,
    .adv_type = ADV_TYPE_IND,
    .own_addr_type = BLE_ADDR_TYPE_PUBLIC,
    .channel_map = ADV_CHNL_ALL,
    .adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

static void set_rele(uint8_t state) {
    rele_state = state ? 1 : 0;
    gpio_set_level(RELE_PIN, !rele_state);  // Relé invertido (LOW activa relé)
}

static void save_to_history(operation_mode_t mode, uint16_t p1, uint16_t p2) {
    history[history_index].timestamp = (uint32_t)time(NULL);
    history[history_index].mode = mode;
    history[history_index].param1 = p1;
    history[history_index].param2 = p2;
    history_index = (history_index + 1) % HISTORY_SIZE;
}

static void operation_task(void *pvParameters) {
    uint32_t elapsed_seconds = 0;

    while (1) {
        vTaskDelay(1000 / portTICK_PERIOD_MS); // Esperar 1 segundo exacto
        elapsed_seconds++;

        if (current_mode == MODE_TIMER) {
            ESP_LOGD(TAG, "Timer: %lu/%d segundos", elapsed_seconds, timer_duration);

            if (elapsed_seconds >= timer_duration) {
                set_rele(0);
                ESP_LOGI(TAG, "✓ Timer completado (%d segundos), LED OFF", timer_duration);
                current_mode = MODE_MANUAL;
                operation_task_handle = NULL;
                vTaskDelete(NULL);
                return;
            }

        } else if (current_mode == MODE_CYCLES) {
            uint32_t cycle_period = cycle_on_time + cycle_off_time;
            uint32_t position_in_cycle = elapsed_seconds % cycle_period;

            uint8_t should_be_on = (position_in_cycle < cycle_on_time) ? 1 : 0;

            if (should_be_on != rele_state) {
                set_rele(should_be_on);
                if (should_be_on) {
                    ESP_LOGI(TAG, "⚡ Cycle ON (en ciclo: %lu/%d segundos)",
                             position_in_cycle, cycle_on_time);
                } else {
                    ESP_LOGI(TAG, "⚫ Cycle OFF (esperando: %lu/%d segundos)",
                             position_in_cycle - cycle_on_time, cycle_off_time);
                }
            }

        } else {
            // Modo manual, terminar tarea
            operation_task_handle = NULL;
            vTaskDelete(NULL);
            return;
        }
    }
}

static bool validate_pin_and_parse(const uint8_t *data, uint16_t len, uint8_t *cmd,
                                   operation_mode_t *mode, uint16_t *p1, uint16_t *p2) {
    if (len < 10) {
        ESP_LOGW(TAG, "❌ Invalid command length: %d (expected 10)", len);
        return false;
    }

    const char *pin = BLE_PIN;
    for (int i = 0; i < 4; i++) {
        if ((char)data[i] != pin[i]) {
            failed_attempts++;
            ESP_LOGW(TAG, "🚨 Invalid PIN attempt #%lu", failed_attempts);
            return false;
        }
    }

    *cmd = data[4];
    *mode = (operation_mode_t)data[5];
    *p1 = (data[6] | (data[7] << 8));
    *p2 = (data[8] | (data[9] << 8));

    failed_attempts = 0;
    return true;
}

static void get_current_status(uint8_t *response, uint16_t *response_len) {
    // Protocolo Extendido (10 bytes):
    // [0] MODE | [1-2] TIME_REMAINING | [3-4] TOTAL_PHASE_TIME | [5] LED_STATE
    // [6] PHASE_INFO (0=ON, 1=OFF) | [7-9] OPERATION_ELAPSED_MS

    uint32_t total_ms_elapsed = (xTaskGetTickCount() - operation_start_time) * 10;  // xTaskGetTickCount está en centisegundos
    uint32_t seconds_elapsed = total_ms_elapsed / 1000;
    uint16_t time_remaining = 0;
    uint16_t total_phase_time = 0;
    uint8_t phase_info = 0;
    uint8_t calculated_rele_state = rele_state;

    response[0] = (uint8_t)current_mode;

    if (current_mode == MODE_TIMER) {
        if (seconds_elapsed >= timer_duration) {
            time_remaining = 0;
            calculated_rele_state = 0;
            phase_info = 0x01; // OFF
        } else {
            time_remaining = timer_duration - seconds_elapsed;
            calculated_rele_state = 1;
            phase_info = 0x00; // ON
        }
        total_phase_time = timer_duration;

    } else if (current_mode == MODE_CYCLES) {
        uint32_t cycle_period = cycle_on_time + cycle_off_time;
        uint32_t position_in_cycle = seconds_elapsed % cycle_period;

        if (position_in_cycle < cycle_on_time) {
            // Fase ON
            time_remaining = cycle_on_time - position_in_cycle;
            total_phase_time = cycle_on_time;
            phase_info = 0x00; // ON
            calculated_rele_state = 1;
        } else {
            // Fase OFF
            time_remaining = cycle_period - position_in_cycle;
            total_phase_time = cycle_off_time;
            phase_info = 0x01; // OFF
            calculated_rele_state = 0;
        }
    } else {
        // MODO MANUAL
        time_remaining = 0;
        total_phase_time = 0;
        // phase_info refleja el estado actual del LED
        phase_info = calculated_rele_state ? 0x00 : 0x01;
    }

    // [5] LED_STATE - usar valor calculado para mayor precisión
    response[5] = calculated_rele_state;

    // [1-2] TIME_REMAINING (little-endian)
    response[1] = time_remaining & 0xFF;
    response[2] = (time_remaining >> 8) & 0xFF;

    // [3-4] TOTAL_PHASE_TIME (little-endian)
    response[3] = total_phase_time & 0xFF;
    response[4] = (total_phase_time >> 8) & 0xFF;

    // [6] PHASE_INFO
    response[6] = phase_info;

    // [7-9] OPERATION_ELAPSED_MS (little-endian, 3 bytes)
    uint32_t elapsed_centiseconds = total_ms_elapsed / 10; // Convertir a centisegundos (10ms precision)
    response[7] = elapsed_centiseconds & 0xFF;
    response[8] = (elapsed_centiseconds >> 8) & 0xFF;
    response[9] = (elapsed_centiseconds >> 16) & 0xFF;

    *response_len = 10;

    ESP_LOGI(TAG,
        "📊 Status: mode=%d, phase=%s, time=%d, total=%d, LED=%d, elapsed=%" PRIu32 "ms",
        current_mode, phase_info == 0 ? "ON" : "OFF",
        time_remaining, total_phase_time, calculated_rele_state, total_ms_elapsed);
}

static void notification_task(void *arg) {
    // Esperar un poco para que Flutter configure CCCD
    vTaskDelay(2000 / portTICK_PERIOD_MS);
    ESP_LOGI(TAG, "📡 Notification task started");

    while (1) {
        vTaskDelay(1000 / portTICK_PERIOD_MS);

        if (conn_id >= 0 && gatts_if != ESP_GATT_IF_NONE) {
            uint8_t status[10];
            uint16_t status_len;
            get_current_status(status, &status_len);

            esp_ble_gatts_send_indicate(gatts_if, conn_id, char_handle,
                                        status_len, status, false);
        }
    }
}

static void gap_event_handler(esp_gap_ble_cb_event_t event, esp_ble_gap_cb_param_t *param) {
    switch (event) {
        case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
            if (param->adv_start_cmpl.status == ESP_BT_STATUS_SUCCESS) {
                ESP_LOGI(TAG, "✓ Advertising started - BombaESP visible");
                ESP_LOGI(TAG, "🔐 BLE PIN: %s (required for pairing)", BLE_PIN);
            }
            break;
        default:
            break;
    }
}

static void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if_param, esp_ble_gatts_cb_param_t *param) {
    switch (event) {
        case ESP_GATTS_REG_EVT:
            ESP_LOGI(TAG, "✓ GATTS app registered");
            gatts_if = gatts_if_param;
            esp_ble_gap_set_device_name(BLE_DEVICE_NAME);
            esp_ble_gap_config_adv_data(&adv_data);

            esp_gatt_srvc_id_t service_id;
            service_id.is_primary = true;
            service_id.id.uuid.len = ESP_UUID_LEN_128;
            memcpy(service_id.id.uuid.uuid.uuid128, service_uuid_128, 16);

            ESP_ERROR_CHECK(esp_ble_gatts_create_service(gatts_if_param, &service_id, 4));
            break;

        case ESP_GATTS_CREATE_EVT:
            service_handle = param->create.service_handle;
            ESP_LOGI(TAG, "✓ Service created (handle=%d)", service_handle);

            esp_bt_uuid_t char_uuid;
            char_uuid.len = ESP_UUID_LEN_128;
            memcpy(char_uuid.uuid.uuid128, char_uuid_128, 16);

            esp_gatt_char_prop_t char_prop = (ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_NOTIFY);

            ESP_ERROR_CHECK(esp_ble_gatts_add_char(service_handle, &char_uuid,
                                                   ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
                                                   char_prop, NULL, NULL));
            break;

        case ESP_GATTS_ADD_CHAR_EVT:
            char_handle = param->add_char.attr_handle;
            ESP_LOGI(TAG, "✓ Characteristic added (handle=%d)", char_handle);

            esp_bt_uuid_t cccd_uuid;
            cccd_uuid.len = ESP_UUID_LEN_16;
            cccd_uuid.uuid.uuid16 = ESP_GATT_UUID_CHAR_CLIENT_CONFIG;

            ESP_ERROR_CHECK(esp_ble_gatts_add_char_descr(service_handle, &cccd_uuid,
                                                         ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
                                                         NULL, NULL));
            break;

        case ESP_GATTS_ADD_CHAR_DESCR_EVT:
            cccd_handle = param->add_char_descr.attr_handle;
            ESP_LOGI(TAG, "✓ CCCD Descriptor added (handle=%d)", cccd_handle);
            esp_ble_gatts_start_service(service_handle);
            break;

        case ESP_GATTS_WRITE_EVT:
            // Manejar escritura del descriptor CCCD
            if (param->write.handle == cccd_handle) {
                uint16_t notify_val = param->write.value[0] | (param->write.value[1] << 8);
                if (notify_val == 0x0001 || notify_val == 0x0002) {
                    ESP_LOGI(TAG, "✓ Notifications enabled (CCCD write received)");
                } else {
                    ESP_LOGI(TAG, "⚫ Notifications disabled (CCCD write received)");
                }
                esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
                                           param->write.trans_id, ESP_GATT_OK, NULL);
                break;
            }

            // Manejar comandos en la característica principal
            if (param->write.handle == char_handle && param->write.len > 0) {
                // Comando especial: GET_STATUS = PIN + 0xFF
                if (param->write.len >= 5 && param->write.value[4] == 0xFF) {
                    const char *pin = BLE_PIN;
                    bool pin_ok = true;
                    for (int i = 0; i < 4; i++) {
                        if ((char)param->write.value[i] != pin[i]) {
                            pin_ok = false;
                            break;
                        }
                    }

                    if (pin_ok) {
                        uint8_t response[10];
                        uint16_t response_len;
                        get_current_status(response, &response_len);

                        esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
                                                   param->write.trans_id, ESP_GATT_OK, NULL);
                        esp_ble_gatts_send_indicate(gatts_if, param->write.conn_id, char_handle,
                                                   response_len, response, false);
                        break;
                    }
                }

                uint8_t cmd = 0;
                operation_mode_t mode = MODE_MANUAL;
                uint16_t p1 = 0, p2 = 0;

                if (validate_pin_and_parse(param->write.value, param->write.len, &cmd, &mode, &p1, &p2)) {

                    // Cancelar tarea anterior si existe
                    if (operation_task_handle != NULL) {
                        vTaskDelete(operation_task_handle);
                        operation_task_handle = NULL;
                    }

                    if (mode == MODE_MANUAL) {
                        set_rele(cmd);
                        current_mode = MODE_MANUAL;
                        ESP_LOGI(TAG, "✅ Manual: LED %s (PIN validated)", cmd ? "ON" : "OFF");
                        save_to_history(MODE_MANUAL, cmd, 0);

                    } else if (mode == MODE_TIMER) {
                        if (p1 > 0 && p1 <= MAX_TIMER_SECONDS) {
                            set_rele(1);
                            timer_duration = p1;
                            current_mode = MODE_TIMER;
                            operation_start_time = xTaskGetTickCount();
                            xTaskCreate(operation_task, "op_task", 2048, NULL, 10, &operation_task_handle);
                            ESP_LOGI(TAG, "⏱️ Timer iniciado: %d segundos (LED ON)", timer_duration);
                            save_to_history(MODE_TIMER, p1, 0);
                        } else {
                            ESP_LOGW(TAG, "❌ Timer invalido: %d (max %d)", p1, MAX_TIMER_SECONDS);
                        }

                    } else if (mode == MODE_CYCLES) {
                        if (p1 >= MIN_CYCLE_SECONDS && p2 >= MIN_CYCLE_SECONDS &&
                            p1 <= MAX_TIMER_SECONDS && p2 <= MAX_TIMER_SECONDS) {
                            set_rele(1);
                            cycle_on_time = p1;
                            cycle_off_time = p2;
                            current_mode = MODE_CYCLES;
                            operation_start_time = xTaskGetTickCount();
                            xTaskCreate(operation_task, "op_task", 2048, NULL, 10, &operation_task_handle);
                            ESP_LOGI(TAG, "🔄 Ciclos iniciados: %dON / %dOFF", cycle_on_time, cycle_off_time);
                            save_to_history(MODE_CYCLES, p1, p2);
                        } else {
                            ESP_LOGW(TAG, "❌ Ciclos invalidos: ON=%d OFF=%d (min %d, max %d)",
                                   p1, p2, MIN_CYCLE_SECONDS, MAX_TIMER_SECONDS);
                        }
                    }

                    if (!param->write.is_prep) {
                        esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
                                                   param->write.trans_id, ESP_GATT_OK, NULL);
                    }
                } else {
                    ESP_LOGW(TAG, "❌ Command rejected - invalid PIN");
                    if (!param->write.is_prep) {
                        esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
                                                   param->write.trans_id, ESP_GATT_INSUF_AUTHENTICATION, NULL);
                    }
                }
            }
            break;

        case ESP_GATTS_CONNECT_EVT:
            conn_id = param->connect.conn_id;
            ESP_LOGI(TAG, "✓ Client connected (conn_id=%d)", conn_id);
            if (notification_task_handle == NULL) {
                xTaskCreate(notification_task, "notif_task", 2048, NULL, 5, &notification_task_handle);
            }
            break;

        case ESP_GATTS_DISCONNECT_EVT:
            ESP_LOGI(TAG, "✓ Client disconnected - restarting advertising");
            conn_id = 0;
            if (notification_task_handle != NULL) {
                vTaskDelete(notification_task_handle);
                notification_task_handle = NULL;
            }
            esp_ble_gap_start_advertising(&adv_params);
            break;

        case ESP_GATTS_START_EVT:
            ESP_LOGI(TAG, "✓ Service started, starting advertising");
            esp_ble_gap_start_advertising(&adv_params);
            break;

        default:
            break;
    }
}

void app_main(void) {
    ESP_LOGI(TAG, "═══════════════════════════════════════════════════");
    ESP_LOGI(TAG, "   Phase 31: Relé Deploy (Production)");
    ESP_LOGI(TAG, "   ⚙️  Solo control de relé, sin LED");
    ESP_LOGI(TAG, "═══════════════════════════════════════════════════");

    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_bt_controller_init(&bt_cfg));
    ESP_ERROR_CHECK(esp_bt_controller_enable(ESP_BT_MODE_BLE));
    ESP_ERROR_CHECK(esp_bluedroid_init());
    ESP_ERROR_CHECK(esp_bluedroid_enable());

    esp_ble_gap_set_device_name(BLE_DEVICE_NAME);

    esp_ble_gap_register_callback(gap_event_handler);
    esp_ble_gatts_register_callback(gatts_event_handler);
    esp_ble_gatts_app_register(GATTS_APP_ID);

    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << RELE_PIN),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    gpio_config(&io_conf);
    gpio_set_level(RELE_PIN, 1);

    ESP_LOGI(TAG, "✓ Relé on GPIO%d", RELE_PIN);
    ESP_LOGI(TAG, "✓ BLE initialized, waiting for connections...");
    ESP_LOGI(TAG, "📋 Supported modes: Manual | Timer | Ciclos");
}
