extends Node

##Default settings for if they are reset
const DEFAULT_SETTINGS : Dictionary = {
	"master_volume": 0.5,
	"music_volume": 0.5,
	"sfx_volume": 0.5
}

##The currently applicable settings as loaded by the settings.json file.
var current_settings : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

##Retrieves the value of a global setting, returns the default setting if not found in the currently
## applied settings.
func _retrieve_setting(setting):
	if (current_settings.has(setting)):
		return current_settings[setting]
	else:
		return DEFAULT_SETTINGS[setting]
