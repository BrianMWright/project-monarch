## game_init.gd
## Diagnostic autoload — runs before main scene, remove before release.
extends Node

func _ready() -> void:
	# push_error appears in logcat even in release builds
	push_error("[GameInit] AUTOLOAD RUNNING")
	push_error("[GameInit] OS: %s" % OS.get_name())
	push_error("[GameInit] Screen: %s" % str(DisplayServer.window_get_size()))
	push_error("[GameInit] Main scene setting: %s" % ProjectSettings.get_setting("application/run/main_scene", "NOT SET"))

	# Write a file so we can confirm execution via: adb shell cat /data/data/com.monarchgame.app/files/godot_diag.txt
	var f := FileAccess.open("user://godot_diag.txt", FileAccess.WRITE)
	if f:
		f.store_string("AUTOLOAD_RAN=YES\n")
		f.store_string("OS=%s\n" % OS.get_name())
		f.store_string("SCREEN=%s\n" % str(DisplayServer.window_get_size()))
		f.close()
		push_error("[GameInit] Wrote user://godot_diag.txt OK")
	else:
		push_error("[GameInit] WARNING: could not write diagnostic file")
