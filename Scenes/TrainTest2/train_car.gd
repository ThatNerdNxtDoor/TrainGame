class_name TrainCar
extends AnimatableBody3D


## Length of the car, end to end, in meters. Used to work out spacing between cars. 
## When the game starts (see _ready), this will be measured automatically. This value will be used to space the cars. The default values are just kinda here now.
## Just be sure to never scale the MeshInstance3D node (its transform -> scale). This will break the automatic car_length algo.
var car_length : float = 14.0

## Meters from the cars center to each wheel set (front and rear). 
@export var bogie_offset : float = 5.0

## Half the height of the car model. This should allow the car to sit on top of the track as opposed to having the track in the middle of the car.
@export var ride_height: float = 0.5 

## The track this car rides on. 
@export var track : Path3D

# Runs once when the car enters the game, before a physics tick. Measures the car's model
# so that the train spaces cars by their real length.
func _ready() -> void:
	var model := $MeshInstance3D as MeshInstance3D
	if model != null:
		car_length = model.get_aabb().size.z

## Given a distance along the track, this function puts the car there. 
func place_on_track(distance: float) -> void: 
	var curve := track.curve # Grab the track's shape, drawn with Path3D.
	var length := curve.get_baked_length() # How long the track is, in meters I believe. 
	
	# fposmod(..., length) note: Wraps the distance around. If 105m is asked for a 100m loop, you get 5m, so the car loops instead of running off the end. 
	var front := curve.sample_baked(fposmod(distance + bogie_offset, length)) # Find the point on the track 5 meters ahead of the car's center. Front wheels are here. 
	var rear := curve.sample_baked(fposmod(distance - bogie_offset, length)) # Same, but back wheels.
	
	var front_global := track.global_transform * front # The curve gives positions measured from the Path3D node. These two lines convert them into world positions. 
	var rear_global := track.global_transform * rear
	
	var middle := (front_global + rear_global) / 2.0 # The point halfway between the two wheel sets - this is where the car's center goes.
	var facing := Basis.looking_at(front_global - rear_global, Vector3.UP) # A rotation that points the car from the rear wheels towards the front wheels, with its roof facing up.
	middle += facing.y * ride_height # facing.y is the car's "up" arrow, exactly 1m long. Facing is the car's rotation. and .y is the part that shows which way is up for the car.
	# With ride height, that 1m becomes 0.5m
	
	global_transform = Transform3D(facing, middle) # Finally, move the car. Put it at middle, turned to facing. 
	# Note that global_transform needs two things: a rotation and a position. 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
