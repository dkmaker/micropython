# pico-hid boot fix (frozen main.py)
# 1. Forces USB re-enumeration so CDC TX works after initial boot
# 2. Then loads hid_device.py from filesystem if present
import usb.device, time

usb.device.get().init(builtin_driver=True)
time.sleep_ms(600)

# Load the real application from filesystem (not shadowed since we ARE main.py)
try:
    exec(open("hid_device.py").read())
except OSError:
    pass  # no hid_device.py deployed yet — fall through to REPL
