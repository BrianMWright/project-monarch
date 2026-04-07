## game_init.gd
## Diagnostic autoload — runs before main scene, remove before release.
extends Node

func _ready() -> void:
	print("=== [GameInit] AUTOLOAD RUNNING ===")
	print("[GameInit] OS: %s" % OS.get_name())
	print("[GameInit] Screen size: %s" % str(DisplayServer.window_get_size()))
	print("[GameInit] Renderer: %s" % RenderingServer.get_rendering_device().get_device_name() if RenderingServer.get_rendering_device() != null else "[GameInit] Renderer: (no RD - using compat)")
	print("[GameInit] main scene: %s" % ProjectSettings.get_setting("application/run/main_scene", "NOT SET"))
