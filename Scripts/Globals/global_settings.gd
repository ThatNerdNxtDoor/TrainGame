extends Node

##The const filepath used for accessing save data.
const SETTINGS_FILE_PATH = "user://settings.json"

##Default settings for if they are reset
const DEFAULT_SETTINGS : Dictionary = {
	"master_volume": 0.5,
	"music_volume": 0.5,
	"sfx_volume": 0.5,
	"window_mode": "windowed", # windowed, fullscreen, borderless, maximized
	"resolution_width": 1920,
	"resolution_height": 1080,
	"target_monitor": 0,
	"vsync_mode": "enabled", # disabled, enabled, adaptive
	"max_fps": 0, # 0 = unlimited
	"shadow_quality": "medium", # off, low, medium, high
	"antialiasing": "2x", # off, 2x, 4x, 8x
}

##The currently applicable settings as loaded by the settings.json file.
var current_settings : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_settings()
	apply_all_settings()

##Retrieves the value of a global setting, returns the default setting if not found in the currently
## applied settings.
func _retrieve_setting(setting):
	if (current_settings.has(setting)):
		return current_settings[setting]
	else:
		return DEFAULT_SETTINGS[setting]

##Loads settings from disk into current_settings, creating the file with defaults if it
## doesn't exist yet or has become unreadable.
func _load_settings():
	if (!FileAccess.file_exists(SETTINGS_FILE_PATH)):
		current_settings = DEFAULT_SETTINGS.duplicate()
		_save_settings()
		return

	var saved_settings = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(saved_settings.get_as_text())
	saved_settings.close()

	current_settings = parsed if parsed is Dictionary else DEFAULT_SETTINGS.duplicate()

##Writes current_settings to disk, overwriting whatever was previously saved.
func _save_settings():
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(current_settings, "\t"))
	file.close()

##Applies every currently loaded setting to the running game/engine state. Called on startup
## and whenever the settings panel wants a live preview of a change.
func apply_all_settings():
	apply_display_settings()
	apply_graphics_settings()
	apply_audio_settings()

##Applies window mode, resolution, target monitor, vsync and the frame rate cap.
func apply_display_settings():
	match _retrieve_setting("window_mode"):
		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		"maximized":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_: #windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var width = int(_retrieve_setting("resolution_width"))
			var height = int(_retrieve_setting("resolution_height"))
			DisplayServer.window_set_size(Vector2i(width, height))

	#Numbers round-tripped through JSON come back as float, so int() is required here even
	# though these settings are conceptually integers.
	var monitor = int(_retrieve_setting("target_monitor"))
	if (monitor >= 0 and monitor < DisplayServer.get_screen_count()):
		DisplayServer.window_set_current_screen(monitor)

	match _retrieve_setting("vsync_mode"):
		"disabled":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		"adaptive":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		_: #enabled
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	Engine.max_fps = int(_retrieve_setting("max_fps"))

##Applies shadow quality and anti-aliasing.
func apply_graphics_settings():
	match _retrieve_setting("shadow_quality"):
		"off":
			RenderingServer.directional_shadow_atlas_set_size(0, true)
			get_viewport().positional_shadow_atlas_size = 0
		"low":
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			get_viewport().positional_shadow_atlas_size = 1024
		"high":
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			get_viewport().positional_shadow_atlas_size = 4096
		_: #medium
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			get_viewport().positional_shadow_atlas_size = 2048

	match _retrieve_setting("antialiasing"):
		"off":
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		"4x":
			get_viewport().msaa_3d = Viewport.MSAA_4X
		"8x":
			get_viewport().msaa_3d = Viewport.MSAA_8X
		_: #2x
			get_viewport().msaa_3d = Viewport.MSAA_2X

##Applies master/music/sfx volume to their audio buses.
func apply_audio_settings():
	_apply_bus_volume("Master", _retrieve_setting("master_volume"))
	_apply_bus_volume("Music", _retrieve_setting("music_volume"))
	_apply_bus_volume("SFX", _retrieve_setting("sfx_volume"))

func _apply_bus_volume(bus_name : String, linear_volume : float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if (bus_index != -1):
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))
