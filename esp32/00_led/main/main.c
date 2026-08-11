#include <stdio.h>
#include <unistd.h>
#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"

#define LED_PIN GPIO_NUM_25
#define BLINK_INTERVAL_MS 1500

static const char *TAG = "LED_FASE0";

void app_main(void) {
    ESP_LOGI(TAG, "=== Fase 0: Parpadeo LED ===");
    ESP_LOGI(TAG, "LED en GPIO%d - Parpadea cada 3 segundos", LED_PIN);

    // Configurar GPIO25 como salida
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << LED_PIN),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };

    gpio_config(&io_conf);
    gpio_set_level(LED_PIN, 0);

    ESP_LOGI(TAG, "Setup completado.\n");

    while (1) {
        // Encender LED
        gpio_set_level(LED_PIN, 1);
        ESP_LOGI(TAG, "LED: ON");
        vTaskDelay(BLINK_INTERVAL_MS / portTICK_PERIOD_MS);

        // Apagar LED
        gpio_set_level(LED_PIN, 0);
        ESP_LOGI(TAG, "LED: OFF");
        vTaskDelay(BLINK_INTERVAL_MS / portTICK_PERIOD_MS);
    }
}
