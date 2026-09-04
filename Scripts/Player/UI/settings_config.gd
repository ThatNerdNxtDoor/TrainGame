extends Panel

@onready var resolution_option : OptionButton = $TabContainer/Video/GridContainer/ResolutionOption
@onready var window_mode_option : OptionButton = $TabContainer/Video/GridContainer/WindowModeOption
@onready var monitor_option : OptionButton = $TabContainer/Video/GridContainer/MonitorOption
@onready var vsync_option : OptionButton = $TabContainer/Video/GridContainer/VsyncOption
@onready var fps_option : OptionButton = $TabContainer/Video/GridContainer/FpsOption
@onready var shadow_option : OptionButton = $TabContainer/Video/GridContainer/ShadowOption
@onready var antialiasing_option : OptionButton = $TabContainer/Video/GridContainer/AntialiasingOption

##Common resolution presets offered in the Resolution dropdown.
const RESOLUTIONS : Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]
const WINDOW_MODES := ["windowed", "fullscreen", "borderless", "maximized"]
const VSYNC_MODES := ["disabled", "enabled", "adaptive"]
##Index 0 is treated as "Unlimited" (max_fps = 0) in the dropdown.
const FPS_OPTIONS := [0, 30, 60, 90, 120, 144, 240]
const SHADOW_QUALITIES := ["off", "low", "medium", "high"]
const AA_OPTIONS := ["off", "2x", "4x", "8x"]

# Called when the node enters the scene tree for the first time.
func _ready():
	_populate_video_options()
	_refresh_video_ui()

##Fills every Video tab dropdown with its selectable options. Only needs to run once since
## the options themselves (aside from monitor count) never change at runtime.
func _populate_video_options():
	resolution_option.clear()
	for res in RESOLUTIONS:
		resolution_option.add_item("%d x %d" % [res.x, res.y])

	window_mode_option.clear()
	window_mode_option.add_item("Windowed")
	window_mode_option.add_item("Fullscreen")
	window_mode_option.add_item("Borderless Fullscreen")
	window_mode_option.add_item("Maximized")

	monitor_option.clear()
	for i in DisplayServer.get_screen_count():
		monitor_option.add_item("Monitor %d" % (i + 1))

	vsync_option.clear()
	vsync_option.add_item("Off")
	vsync_option.add_item("Enabled")
	vsync_option.add_item("Adaptive")

	fps_option.clear()
	fps_option.add_item("Unlimited")
	for fps in FPS_OPTIONS:
		if (fps != 0):
			fps_option.add_item(str(fps))

	shadow_option.clear()
	shadow_option.add_item("Off")
	shadow_option.add_item("Low")
	shadow_option.add_item("Medium")
	shadow_option.add_item("High")

	antialiasing_option.clear()
	antialiasing_option.add_item("Off")
	antialiasing_option.add_item("2x MSAA")
	antialiasing_option.add_item("4x MSAA")
	antialiasing_option.add_item("8x MSAA")

##Selects the dropdown entry matching each value in GlobalSettings.current_settings. Called
## on open and after cancelling so the UI never lies about what's actually applied.
func _refresh_video_ui():
	#int() is required since numbers round-tripped through JSON come back as float.
	var resolution := Vector2i(
		int(GlobalSettings._retrieve_setting("resolution_width")),
		int(GlobalSettings._retrieve_setting("resolution_height"))
	)
	resolution_option.select(maxi(RESOLUTIONS.find(resolution), 0))

	window_mode_option.select(maxi(WINDOW_MODES.find(GlobalSettings._retrieve_setting("window_mode")), 0))
	monitor_option.select(clampi(int(GlobalSettings._retrieve_setting("target_monitor")), 0, monitor_option.item_count - 1))
	vsync_option.select(maxi(VSYNC_MODES.find(GlobalSettings._retrieve_setting("vsync_mode")), 0))
	fps_option.select(maxi(FPS_OPTIONS.find(int(GlobalSettings._retrieve_setting("max_fps"))), 0))
	shadow_option.select(maxi(SHADOW_QUALITIES.find(GlobalSettings._retrieve_setting("shadow_quality")), 0))
	antialiasing_option.select(maxi(AA_OPTIONS.find(GlobalSettings._retrieve_setting("antialiasing")), 0))

##Cancels any setting changes and reverts them to before the panel was opened,
## then closes the panel.
func cancel_changes():
	GlobalSettings._load_settings()
	GlobalSettings.apply_all_settings()
	_refresh_video_ui()

	self.visible = false

##Saves any setting changes made by overwriting previous settings,
## then closes the panel.
func _save_changes():
	GlobalSettings._save_settings()
	self.visible = false

##Switches keybindings for certain actions
func _change_keybind(action, keybind):
	pass

##Signal recieving function for when a setting value is changed. If the setting does not exist in
## current_settings, it is created and inserted into the dictionary.
func _change_setting(setting, value):
	if (GlobalSettings.current_settings.has(setting)):
		GlobalSettings.current_settings[setting] = value
	else:
		GlobalSettings.current_settings.get_or_add(setting, value)

#===============================Video Signal Functions===============================#

func _on_resolution_item_selected(index : int):
	var res = RESOLUTIONS[index]
	_change_setting("resolution_width", res.x)
	_change_setting("resolution_height", res.y)
	GlobalSettings.apply_display_settings()

func _on_window_mode_item_selected(index : int):
	_change_setting("window_mode", WINDOW_MODES[index])
	GlobalSettings.apply_display_settings()

func _on_monitor_item_selected(index : int):
	_change_setting("target_monitor", index)
	GlobalSettings.apply_display_settings()

func _on_vsync_item_selected(index : int):
	_change_setting("vsync_mode", VSYNC_MODES[index])
	GlobalSettings.apply_display_settings()

func _on_fps_item_selected(index : int):
	_change_setting("max_fps", FPS_OPTIONS[index])
	GlobalSettings.apply_display_settings()

func _on_shadow_item_selected(index : int):
	_change_setting("shadow_quality", SHADOW_QUALITIES[index])
	GlobalSettings.apply_graphics_settings()

func _on_antialiasing_item_selected(index : int):
	_change_setting("antialiasing", AA_OPTIONS[index])
	GlobalSettings.apply_graphics_settings()
