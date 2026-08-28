extends Control

@onready var settings_panel = $SettingsPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#===============================Signal Functions===============================#

##Moves to the games next scene (or likely open server browser since it's multiplayer
func start_game():
	pass # Replace with function body.

##Opens the settings panel.
func open_settings():
	settings_panel.visible = true;

##Closes the game.
func close_game():
	get_tree().quit(0)
