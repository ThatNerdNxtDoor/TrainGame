extends Node3D
class_name SpawnerPoint

##An array of PoolProfiles for the enemy spawn pool, including
## the enemy's name, PackedScene, group size, spawn weight, and spawn cost.
@export var spawn_pool : Array[EnemyPoolProfile]
##Determines the "budget" of a wave, using the enemies' [param spawn_pool_cost] as costs to determine
## what to spawn and how much they can spawn at each spawn point. Initial value determines the
## budget of the first wave, and budget increases for each following wave. 
@export var wave_budget : float = 100.0
##The name of the node group that the spawner uses to place the enemies.
@export var spawner_group : String = "WaveSpawner"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

##To be called by an external signal to spawn enemies in accordance to its assigned [param spawn_pool].
func _spawn_wave():
	##TODO: Maybe provide an initial behavior to the enemies so that they will spread out.
	var spawn_points = get_tree().get_nodes_in_group(spawner_group)
	#Divy out enemies across the spawn locations
	for point in spawn_points:
		#Check the spawn to see if if condition prevent it from spawning enemies (too many / player near)
		if (!validate_spawn(point)):
			continue
		#Set a standing budget for each point
		var temp_budget = wave_budget
		while temp_budget > 0:
			var spawn_number = randf_range(0, 100.0)
			for profile in spawn_pool:
				if spawn_number <= profile.weighting and temp_budget >= 0:
					#Determine how many enemies are spawned using the profile's grouping variable.
					var group_size = randi_range(profile.grouping[0], profile.grouping[1])
					for i in range(group_size - 1):
						var spawned_enemy = profile.scene.instantiate()
						##TODO: Add a way for the spawner to determine if the enemy can be placed on the
						## generated spot, then keep generating a position until it has a valid one.
						spawned_enemy.position = point.position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
						get_tree().root.add_child(spawned_enemy)
					temp_budget -= profile.cost

##Uses the spawn point to run a shapecast check to see if there are any players nearby or if there are
## too many enemies nearby.
func validate_spawn(point):
	##TODO: Find a way to check for the a player.
	#Create a sphere to do a spawn check to determine if there are too many entities to spawn more.
	var spawn_check = ShapeCast3D.new()
	spawn_check.shape = SphereShape3D.new()
	spawn_check.shape.radius = 8
	#Set the collision mask to only read for enemy entities.
	spawn_check.set_collision_mask_value(1, false)
	spawn_check.set_collision_mask_value(5, true)
	point.add_child(spawn_check)
	spawn_check.force_shapecast_update()
	var spawn_count = spawn_check.get_collision_count()
	print(spawn_count)
	spawn_check.queue_free()
	if (spawn_count >= 8): #If there are too many enemies nearby, don't spawn anymore.
		return false
	else:
		return true
