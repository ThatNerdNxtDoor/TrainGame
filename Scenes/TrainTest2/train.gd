class_name Train
extends Node3D

## The train as a whole. Owns ONE distance and ONE speed, and tells every other car (which are its children), 
## where to stand on the track each tick. Cars never move themselves for now. 
## The order of the cars in the Scene panel is the order on the track. The top car is in the front. 


## Acceleration at full power, in meters per second. 
@export var max_acceleration : float = 0.8

## Deceleration at full brake, in meters per second.
@export var max_braking : float = 1.5

## How much speed is lost per second while coasting (the level is at ) from air and friction. 
@export var coasting_friction : float = 0.05

## The fastest the train can go, in meters per second. 
@export var max_speed : float = 25.0

## How fast the lever moves while a key is held, in "lever units" per second. 
## 0.5 means going from coasting (0) to full power (1) takes 2 seconds of holding the key.
@export var lever_speed : float = 0.5

## The power / brake lever. -1 = full brake, 0 = coast, +1 = full power. Stays where it was left. 
var current_lever_position : float = 0.0

## Current speed of the train. Meters per second.
@export var speed: float = 0.0


## How far along the track the very front of the train is, in meters. This will grow as the train moves along a track.
var distance : float = 0.0


## The space between two couples cars, in meters. 
@export var coupling_gap : float = 2.0

# Runs every physics tick, moves the train forward, then places every car behind the one before it.
func _physics_process(delta: float) -> void:
	# Move the lever while a key is held. get_axis gives -1 (down), 0 (neither), or +1 (held)
	current_lever_position += Input.get_axis("Train_ThrottleDown", "Train_ThrottleUp") * lever_speed * delta
	current_lever_position = clampf(current_lever_position, -1.0, 1.0)
	
	# Work out acceleration now that we have the lever position
	var acceleration : float
	if current_lever_position > 0.0:
		acceleration = current_lever_position * max_acceleration # Speed up
	else:
		acceleration = current_lever_position * max_braking # Slow down
		
	speed = clampf(speed + acceleration * delta, 0.0, max_speed)
	
	distance += speed * delta
	
	# Where the front end of the next car should be. This will, of course, start at the very front of the train.
	var front_end := distance
	
	
	
	for child in get_children():
		# Only TrainCars get placed. Anything else under Train (sounds, effects, etc) is skipped.
		var car := child as TrainCar
		if car == null:
			continue
		
		# This car's center is half its own length behind its own front end.
		var center := front_end - car.car_length / 2.0
		car.place_on_track(center)
		
		# Move back past the rest of this car and the coupling gap. This is where the next car starts. 
		front_end = center - car.car_length / 2.0 - coupling_gap
