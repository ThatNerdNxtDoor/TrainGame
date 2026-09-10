extends RigidBody3D
class_name EnemyProjectile

@export var collision_box : CollisionShape3D

@export var projectile_mesh : MeshInstance3D

@export var damage : int = 10

#--------------------------------------------------------------------------------------------------#
@export_group("Initial Force")

## The base force multiplier the projectile is shot at by its firer.
@export var base_force : float = 8

## The floor of the random multipler that affects projectile force. Must be smaller than
## [param random_force_ceiling].
@export_range(0, 10, .01, "prefer_slider") var random_force_floor = 1.0

## The ceiling of the random multiplier that affects projectile force. Must be larger than
## [param random_force_floor].
@export_range(1, 10,.01, "prefer_slider") var random_force_ceiling = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func connect_signals():
	collision_box.body_entered.connect(projectile_collision)
	pass

func projectile_collision():
	self.queue_free()
	pass
