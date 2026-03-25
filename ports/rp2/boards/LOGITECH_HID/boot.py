# pico-hid boot fix
# Forces USB re-enumeration so CDC TX works after initial boot.
# After this runs, the Pico soft-resets back to a clean REPL that mpremote can use.
import usb.device, time

usb.device.get().init(builtin_driver=True)
time.sleep_ms(600)
