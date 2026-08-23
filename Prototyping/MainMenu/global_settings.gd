extends Node

const DEFAULT_SETTINGS : Dictionary = { #Default settings for if they are reset
	"master_volume": 0.5,
	"music_volume": 0.5,
	"sfx_volume": 0.5
}

var current_settings : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Retrieves the value of a global setting, returns the default setting if not found.
func _retrieve_setting(setting):
	return current_settings[setting]
