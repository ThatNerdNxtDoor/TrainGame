extends Enemy
class_name RangedEnemy

@export var projectile : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_actor_setup.call_deferred()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
