extends PathFollow3D

@export var car_ahead : PathFollow3D
@export var spacing : float = 15.0

func _physics_process(delta: float) -> void:
	var curve_length : float = get_parent().curve.get_baked_length()
	progress = fposmod(car_ahead.progress - spacing, curve_length)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
