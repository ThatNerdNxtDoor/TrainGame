extends Panel

var current_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

##Cancels any setting changes and reverts them to before the panel was opened,
## then closes the panel.
func cancel_changes():
	self.visible = false
	pass # Replace with function body.

##Saves any setting changes made by overwriting previous settings,
## then closes the panel.
func _on_save_changes_pressed():
	self.visible = false
	pass # Replace with function body.
