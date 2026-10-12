extends Resource
class_name EnemyPoolProfile

##The Name of the enemy/enemies.
@export var name : String = "Generic"
##The scene that respresents the enemy and gets instantiated.
@export var scene : PackedScene
##How many times the enemy in the profile is spawned (ideal for swarms). The number is
## randomly generated, where Index 0 is lower bound and Index 1 is upper bound.
@export var grouping : Array[int] = [1, 1]
##The weight/chance (out of 100) for the enemy profile to be spawned per loop.
@export var weighting : float = 100.0
##The budget cost of spawning this enemy profile.
@export var cost : float = 40.0
