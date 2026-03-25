// Board and hardware specific configuration
// Impersonates a Logitech Unifying Receiver (046D:C52B) for stealth HID operation.
// Based on RPI_PICO2_W — all hardware features retained (WiFi, BLE, etc.)

#define MICROPY_HW_BOARD_NAME                   "Raspberry Pi Pico 2 W"
#define MICROPY_HW_FLASH_STORAGE_BYTES          (PICO_FLASH_SIZE_BYTES - 1536 * 1024)

// ── USB Identity ─────────────────────────────────────────────────────────────
// Appears as: "Logitech, Inc.  USB Receiver" — identical to a Logitech MK series dongle
#define MICROPY_HW_USB_VID                      (0x046D)  // Logitech, Inc.
#define MICROPY_HW_USB_PID                      (0xC52B)  // Unifying Receiver (MK270/MK320/MK520)
#define MICROPY_HW_USB_MANUFACTURER_STRING      "Logitech"
#define MICROPY_HW_USB_PRODUCT_FS_STRING        "USB Receiver"
#define MICROPY_HW_USB_CDC_INTERFACE_STRING     "USB Receiver"

// ── Networking (CYW43) ───────────────────────────────────────────────────────
#define MICROPY_PY_NETWORK 1
#define MICROPY_PY_NETWORK_HOSTNAME_DEFAULT     "Pico2W"

#define CYW43_USE_SPI (1)
#define CYW43_LWIP (1)
#define CYW43_GPIO (1)
#define CYW43_SPI_PIO (1)

#define MICROPY_HW_PIN_EXT_COUNT    CYW43_WL_GPIO_COUNT

int mp_hal_is_pin_reserved(int n);
#define MICROPY_HW_PIN_RESERVED(i) mp_hal_is_pin_reserved(i)
