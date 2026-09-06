extends RigidBody3D
class_name EnemyProjectile

@export var collision_box : CollisionShape3D

@export var projectile_mesh : MeshInstance3D

#--------------------------------------------------------------------------------------------------#
@export_group("Initial Force")

@export var base_force : float

@export_range(0, 2,.01,"prefer_slider") var random_force_multiplier = 1.0

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
