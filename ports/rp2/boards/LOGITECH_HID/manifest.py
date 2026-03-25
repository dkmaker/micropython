include("$(PORT_DIR)/boards/manifest.py")

require("bundle-networking")

# Bluetooth
require("aioble")

# Boot fix: frozen main.py forces USB re-enumeration so CDC TX works
freeze("$(BOARD_DIR)", "boot.py")
