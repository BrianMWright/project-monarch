## game_init.gd
## Diagnostic autoload — runs before main scene, remove before release.
extends Node

func _ready() -> void:
	# Use push_error on-device so it shows in logcat, but keep CI/headless logs clean.
	var is_ci := OS.get_environment("CI") == "true"
	var is_android := OS.get_name() == "Android" or OS.has_feature("android")
	var log := func(message: String) -> void:
		if is_android and not is_ci:
			push_error(message)
		else:
			print(message)

	log.call("[GameInit] AUTOLOAD RUNNING")
	log.call("[GameInit] OS: %s" % OS.get_name())
	log.call("[GameInit] Screen: %s" % str(DisplayServer.window_get_size()))
	log.call("[GameInit] Main scene setting: %s" % ProjectSettings.get_setting("application/run/main_scene", "NOT SET"))

	# Write a file so we can confirm execution via: adb shell cat /data/data/com.monarchgame.app/files/godot_diag.txt
	var f := FileAccess.open("user://godot_diag.txt", FileAccess.WRITE)
	if f:
		f.store_string("AUTOLOAD_RAN=YES\n")
		f.store_string("OS=%s\n" % OS.get_name())
		f.store_string("SCREEN=%s\n" % str(DisplayServer.window_get_size()))
		f.close()
		log.call("[GameInit] Wrote user://godot_diag.txt OK")
	else:
		log.call("[GameInit] WARNING: could not write diagnostic file")
