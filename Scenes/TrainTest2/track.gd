class_name Track
extends Node3D

## The whole railway line. Its children are Path3D segments, joined end-to-end in the Scene panel.
## The order: Top = first. Anything that needs a position on the line asks this node, not the curve itself.

## If true, the line is a closed loop: going past the end continues from the start. 
## Otherwise, positions past either end stop at that end

@export var loops : bool = true

## The total length of the whole lone, in meters. All segments added together. 

func get_length() -> float:
	var total := 0.0
	for child in get_children():
		var segment := child as Path3D
		if segment == null:
			continue
		total += segment.curve.get_baked_length()
	return total
	
## The world position at `distance` metres along the whole line.
func position_at(distance: float) -> Vector3:
	# Keep the distance inside the line: wrap around on a loop, otherwise stop at the ends.
	if loops:
		distance = fposmod(distance, get_length())
	else:
		distance = clampf(distance, 0.0, get_length())
	
	# Walk through the segments in order, subtracting each one's length
	# until the distance that is left fits inside a segment. 
	var end_of_last_segment := Vector3.ZERO
	for child in get_children():
		var segment := child as Path3D
		if segment == null:
			continue
		var segment_length := segment.curve.get_baked_length()
		if distance <= segment_length:
			# Found it: Sample this segment, then convert from the segment's own spafce to the world space. 
			return segment.global_transform * segment.curve.sample_baked(distance)
		distance -= segment_length
		end_of_last_segment = segment.global_transform * segment.curve.sample_baked(segment_length)
	return end_of_last_segment
	
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
