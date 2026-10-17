class_name TrainCar
extends AnimatableBody3D


## Length of the car, end to end, in meters. Used to work out spacing between cars. 
@export var car_length : float = 14.0

## Meters from the cars center to each wheel set (front and rear). 
@export var bogie_offset : float = 5.0

## Half the height of the car model. This should allow the car to sit on top of the track as opposed to having the track in the middle of the car.
@export var ride_height: float = 0.5 








## The track this car rides on. 
@export var track : Path3D

## Temporary: Meters per second. The train controller will replace this, but keeping this here for now. 
@export var test_speed : float = 10.0

var center_distance : float = 0.0

func _physics_process(delta: float) -> void:
	center_distance += test_speed * delta # TEMPORARY
	place_on_track(center_distance)
	
	
## Given a distance along the track, this function puts the car there. 
## Each tick (_physics_process), adds a bit to center_distance and calls this function, which moves the car. 
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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
