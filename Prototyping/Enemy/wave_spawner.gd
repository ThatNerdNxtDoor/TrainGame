extends Node3D

##TODO: Maybe change these arrays into a single array of of arrays or external data to save space.
##TODO: Maybe code some enemies to spawn in groups with configurable numbers.

##An array of packed scene for enemies that the spawner can choose from when deciding what to spawn.
## Enemies at a lower index have priority in spawning if the spawning function overlaps.
@export var spawn_pool : Array[PackedScene]
##An array of floats that determine the spawn weight (out of 100) of the enemy at the same index of 
## the [param spawn_pool].
@export var spawn_pool_weight : Array[float]
##An array of floats that determine the budget cost to spawn the enemy at the same index at [param spawn_pool].
@export var spawn_pool_cost : Array[float]
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
	##TODO: Maybe get each point to run a function to determine if there are any players/too many enemies
	## nearby to spawn more.
	##TODO: Maybe provide an initial behavior to the enemies so that they will spread out.
	var spawn_points = get_tree().get_nodes_in_group(spawner_group)
	#Divy out enemies across the spawn locations
	for point in spawn_points:
		#Set a standing budget for each point
		var temp_budget = wave_budget
		while temp_budget > 0:
			var spawn_number = randf_range(0, 100.0)
			for index in range(spawn_pool.size()):
				if spawn_number <= spawn_pool_weight[index] and temp_budget >= 0:
					var spawned_enemy = spawn_pool[index].instantiate()
					##TODO: Add a way for the spawner to determine if the enemy can be placed on the
					## generated spot, then keep generating a position until it has a valid one.
					spawned_enemy.position = point.position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
					get_tree().root.add_child(spawned_enemy)
					temp_budget -= spawn_pool_cost[index]
