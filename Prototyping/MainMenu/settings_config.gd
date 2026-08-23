extends Panel

##System settings use a JSON system, so a helper class must be instantiated
var json = JSON.new()
##The const filepath used for accessing save data.
const SETTINGS_FILE_PATH = "user://settings.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	if (!FileAccess.file_exists(SETTINGS_FILE_PATH)): #Settings file does not exist, create a new one.
		#Saving to a nonexistant file creates a new one.
		var new_settings = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
		#The new settings file will inherit the default settings
		new_settings.store_line("{")
		for setting in GlobalSettings.DEFAULT_SETTINGS.keys():
			new_settings.store_line("\"" + setting + "\": " + GlobalSettings.DEFAULT_SETTINGS[setting] + ",")
		new_settings.store_line("}")
		new_settings.close()
	#Load saved settings
	var saved_settings = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	GlobalSettings.current_settings = json.parse_string(saved_settings.get_as_text())
	#TODO: Access settings to load saved settings.
	saved_settings.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

##Cancels any setting changes and reverts them to before the panel was opened,
## then closes the panel.
func cancel_changes():
	#Reloads and reapplies the settings from the parsed file
	var saved_settings = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	GlobalSettings.current_settings = json.parse_string(saved_settings.get_as_text())
	saved_settings.close()
	
	self.visible = false

##Saves any setting changes made by overwriting previous settings,
## then closes the panel.
func _save_changes():
	var new_settings = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	new_settings.store_line("{")
	#TODO: Store collect default settings to store here.
	#Using a group tag, can get every setting node and collect its value property.
	new_settings.store_line("}")
	new_settings.close()
	self.visible = false
	pass # Replace with function body.

##Switches keybindings for certain actions
func _change_keybind(action, keybind):
	pass

##Changes a setting variable
func _change_setting(setting, value):
	pass
