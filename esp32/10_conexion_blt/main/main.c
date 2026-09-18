#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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

#define TAG "BLE_FASE1"
#define LED_PIN GPIO_NUM_25
#define GATTS_APP_ID 0x55

static uint8_t led_state = 0;
static uint16_t gatts_if = ESP_GATT_IF_NONE;
static uint16_t service_handle = 0;
static uint16_t char_handle = 0;

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
            esp_ble_gap_set_device_name("BombaESP");
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

            esp_gatt_char_prop_t char_prop = (ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_WRITE);

            ESP_ERROR_CHECK(esp_ble_gatts_add_char(service_handle, &char_uuid,
                                                   ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
                                                   char_prop, NULL, NULL));
            break;

        case ESP_GATTS_ADD_CHAR_EVT:
            char_handle = param->add_char.attr_handle;
            ESP_LOGI(TAG, "✓ Characteristic added (handle=%d)", char_handle);
            esp_ble_gatts_start_service(service_handle);
            break;

        case ESP_GATTS_WRITE_EVT:
            if (param->write.len > 0) {
                led_state = param->write.value[0];
                gpio_set_level(LED_PIN, led_state ? 1 : 0);
                ESP_LOGI(TAG, "✓ LED: %s", led_state ? "ON" : "OFF");

                if (!param->write.is_prep) {
                    esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
                                               param->write.trans_id, ESP_GATT_OK, NULL);
                }
            }
            break;

        case ESP_GATTS_CONNECT_EVT:
            ESP_LOGI(TAG, "✓ Client connected");
            break;

        case ESP_GATTS_DISCONNECT_EVT:
            ESP_LOGI(TAG, "✓ Client disconnected - restarting advertising");
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
    ESP_LOGI(TAG, "=== Phase 1: BLE Server ===");

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
        .pin_bit_mask = (1ULL << LED_PIN),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    gpio_config(&io_conf);
    gpio_set_level(LED_PIN, 0);

    ESP_LOGI(TAG, "BLE server initialized, waiting for connections...");
}
