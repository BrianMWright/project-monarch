## game_init.gd
## Diagnostic autoload — runs before main scene, remove before release.
extends Node

func _ready() -> void:
	print("[GameInit] AUTOLOAD RUNNING")
	print("[GameInit] OS: %s" % OS.get_name())
	print("[GameInit] Screen: %s" % str(DisplayServer.window_get_size()))
	print("[GameInit] Main scene setting: %s" % ProjectSettings.get_setting("application/run/main_scene", "NOT SET"))

	# Write a file so we can confirm execution via: adb shell cat /data/data/com.monarchgame.app/files/godot_diag.txt
	var f := FileAccess.open("user://godot_diag.txt", FileAccess.WRITE)
	if f:
		f.store_string("AUTOLOAD_RAN=YES\n")
		f.store_string("OS=%s\n" % OS.get_name())
		f.store_string("SCREEN=%s\n" % str(DisplayServer.window_get_size()))
		f.close()
		print("[GameInit] Wrote user://godot_diag.txt OK")
	else:
		push_warning("[GameInit] WARNING: could not write diagnostic file")
