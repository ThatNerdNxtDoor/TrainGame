extends PathFollow3D

## trainSpeed: Modify this to change the speed of the train. May need to implement acceleration / deceleration and perhaps temporary modifiers as well. 
@export var trainSpeed : float = 20

func _physics_process(delta: float) -> void: 
	progress += trainSpeed * delta # REALLY NEED to ensure that this is synched across the server. Hm. 
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
