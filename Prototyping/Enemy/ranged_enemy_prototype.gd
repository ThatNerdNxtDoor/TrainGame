extends Enemy
class_name RangedEnemy

## The Projectile the enemy fires
@export var projectile : PackedScene

## The [Timer] Node the actor uses to decide when to shoot its projectile.
@export var proj_timer : Timer

func enemy_actor_setup():
	# Connect the navigation agent to its needed functions.
	nav_agent.target_reached.connect(_on_navigation_agent_3d_target_reached)
	nav_agent.link_reached.connect(_on_navigation_link_reaced)
	nav_agent.path_desired_distance = 1.5
	nav_agent.target_desired_distance = 1.5
	
	# Connect the navigation timer to the needed functions.
	nav_timer.timeout.connect(_nav_timer_timeout)
	nav_timer.wait_time = nav_time
	nav_timer.one_shot = true
	
	# Connect the aggro area (if it exists).
	if aggro_area != null:
		aggro_area.body_entered.connect(_aggro_entered)
	
	# Connect shot timer to the function that fires the projectile.
	proj_timer.timeout.connect(_shoot_projectile)
	proj_timer.wait_time = 1.0
	proj_timer.one_shot = true
	
	# Wait for the physics frame in the scene to be initialized.
	await get_tree().physics_frame

## Activates the pursuit mode for the Actor. The Actor will continue to move towards the 
## [param pursuit_entity]'s position until the target is at the specified [param engage_distance].
## To function, it is best to have a [CollisionShape3D] to call the function when a valid target enters
## it. /n The Ranged Enemy also starts its [param proj_timer] when pursuing an enemy.
func pursue(target : Node3D):
	# TODO: Change pursuing to have an aggro variable to decide what the enemy should be fighting when
	#	when against multiple opponents.
	# TODO: Move firing to a separate function to make movement and firing more modular.
	# TODO: Add a function for when losing aggro (resetting shot timer, etc)
	# If it is not already pursuing something else, then it will save where it was originally going
	# so that it can return there when the pursuit is over.
	if pursuit_entity == null:
		base_movement_goal = nav_agent.target_position
		proj_timer.start()
	
	pursuit_entity = target
	nav_timer.paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_actor_setup.call_deferred()
	enemy_start_navigation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		pause_navigation = false
		if ground_clamp:
			vel_clamp = true
	
	if !pause_navigation:
		behavior_calculation()
	movement_calculation(delta)
	move_and_slide()

## When the [param proj_timer] runs out, the enemy fires their assigned [param projectile].
func _shoot_projectile():
	# If the enemy currently isn't in combat, do not bother shooting.
	if pursuit_entity:
		# Create projectile, aim it towards the currently aggro'd thing, and launch it with an impulse
		var new_proj = projectile.instantiate()
		get_tree().root.get_children()[0].add_child(new_proj)
		new_proj.apply_central_impulse(
			self.global_position.direction_to(pursuit_entity.global_position) * 
				(new_proj.base_force * randf_range(new_proj.random_force_floor, new_proj.random_force_ceiling)))
		# Restart the timer.
		proj_timer.start()
