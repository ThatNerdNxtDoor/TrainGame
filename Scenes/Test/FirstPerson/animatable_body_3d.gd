extends AnimatableBody3D
## Makes a train car lean ("bank") into curves, based on how fast it is going and how sharply
## the track is bending at the car's position.
##
## WHERE THIS SCRIPT LIVES
## It must be attached to an AnimatableBody3D that is a DIRECT child of a PathFollow3D, which
## must itself be a DIRECT child of a Path3D:
##
##   Path3D                 (owns the Curve3D: the shape of the track)
##     PathFollow3D         (slides along the curve; sets the car's position and base facing direction)
##       AnimatableBody3D   (This script; the solid car the player stands on)
##         MeshInstance3D + CollisionShape3D
##
## The PathFollow3D decides where the car is and which way it faces. This script adds a
## roll (a sideways lean) around the car's own length axis.
## Every car should each own a copy of this script (one file, many instances, each instance with its
## own variables), so each car leans according to the piece of track it is on right now.
##
## Going off of real world physics...
## Going round a bend at speed pushes everything on the train sideways. Real railways tilt the
## track so the floor tilts too; the sideways push then presses passengers into the floor
## instead of shoving them across it. The tilt angle that exactly cancels the push is:
##
##   bank_angle = atan( speed * speed * curvature / gravity )
##
##   speed      how fast the car moves, in metres per second.
##   curvature  how sharply the track bends, in radians per metre. It equals 1 / turn radius:
##              a 50 m radius bend is 0.02, a 200 m bend is 0.005, dead-straight track is 0.
##   gravity    9.8 by default. Used here purely as a tuning constant (see `gravity` below).
##
## Speed is SQUARED, so banking is extremely sensitive to speed. Worked examples (gravity 9.8):
##   speed  2 m/s, 50 m bend  ->  about 0.5 degrees  (you would never notice it)
##   speed 20 m/s, 200 m bend ->  about 11.5 degrees
##   speed 20 m/s, 100 m bend ->  about 22 degrees
##   speed 20 m/s,  50 m bend ->  about 39 degrees, which max_bank_degrees cuts down to 25
##
## Real railways rarely bank more than roughly 6-7 degrees, so a fully "correct" bank looks
## exaggerated. max_bank_degrees is how you choose between realistic and readable.
##
## TUNING CHEAT SHEET
##   Lean too weak ............ raise max_bank_degrees, lower gravity, or raise trainSpeed
##   Every bend leans the same  you are hitting the cap: raise max_bank_degrees or raise gravity
##   Lean looks twitchy/stiff . lower bank_smoothing, or raise sample_offset in _physics_process
##   Lean arrives late ........ raise bank_smoothing
##   Leans OUT of bends ....... see the DIRECTION CHECK at the bottom of _physics_process
##   Changed a number here but nothing happened? If you ever edited that value in the Inspector,
##   the scene file stores that value and it overrides the default written in this script.
##   Look for the little "revert" arrow next to the property in the Inspector.

## The largest lean allowed, in DEGREES, in either direction.
## The formula can ask for huge angles on tight bends at high speed; this is a safety cap so
## the car never rolls over. Raise it for more dramatic lean, lower it for a subtler one.
## 0 turns banking off completely. Note that every bend that reaches the cap leans by exactly
## the same amount, so if it is set too low you lose the difference between gentle and sharp bends.
@export var max_bank_degrees : float = 25.0

## How quickly the actual lean catches up with the ideal lean (roughly "per second").
## Higher = snappier: the car snaps into and out of a lean, which looks stiff or twitchy.
## Lower = lazier: the lean lags behind the track, so the car may still be leaning after the
## bend has ended. Roughly, the lean closes 63% of the gap in 1 / bank_smoothing seconds:
##   4.0 -> about 0.25 s,   1.0 -> about 1 s,   20.0 -> about 0.05 s.
## 0 means the lean never changes from its starting value (level), so no banking at all.
## It also acts as a filter that hides tiny jitters in the measured curvature.
@export var bank_smoothing : float = 4.0

## The "g" in the formula above. 9.8 is Earth's gravity in metres per second squared.
## This is ONLY a tuning knob for the lean. It is NOT connected to the physics engine's gravity
## or to the player's gravity variable.
## Lower value = MORE lean for the same speed and bend. Higher value = LESS lean.
## Keep it above 0: 0 divides by zero, which can produce invalid (NaN) rotations.
@export var gravity : float = 9.8

## The PathFollow3D this car rides on (our direct parent). We read its `progress` (how many
## metres along the track it is right now) to know where on the track this car is.
## @onready means "fill this in just before _ready() runs", at which point the node is in the
## scene tree and get_parent() works. A plain `var x = get_parent()` would run too early,
## before the node has a parent, and give you nothing.
## If this script is attached to a node whose parent is NOT a PathFollow3D, the game stops with
## a type error at startup. That is the script telling you it is in the wrong place.
@onready var path_follow : PathFollow3D = get_parent()

## The Curve3D (the track's shape) owned by the Path3D that is our grandparent.
## `path_follow.get_parent()` is that Path3D, and `.curve` is the Curve3D resource stored on it.
## It is captured ONCE at startup. Edits to that same curve are still seen, but if another
## script later assigns a brand-new Curve3D to the Path3D, this variable keeps pointing at the
## old one.
## It is declared below path_follow on purpose: @onready variables are filled in top to bottom,
## and this one needs path_follow to already exist.
@onready var track_curve : Curve3D = path_follow.get_parent().curve

## The lean the car has RIGHT NOW, in radians (not degrees). It moves gradually toward the ideal
## lean every physics tick (see step 4 in _physics_process). 0 = level. Positive leans one way,
## negative the other.
var current_bank : float = 0.0

## The value of path_follow.progress on the PREVIOUS physics tick. Needed to measure speed:
## speed = how far progress changed / how much time passed.
var previous_progress : float = 0.0

# Runs once when the car enters the scene, before the first physics tick.
func _ready() -> void:
	# Remember where the car starts. Without this, previous_progress would start at 0. If the car
	# began at, say, 300 m along the track, the first tick would measure a jump of 300 m in one
	# tick (a "speed" of thousands of m/s) and the car would flick to a big lean for a moment.
	# Follower cars set their own progress on their first tick (after this line has run), so they
	# may still show one tiny, momentary twitch at startup. It fades within a fraction of a second.
	previous_progress = path_follow.progress

# Runs once per PHYSICS tick (60 times a second by default), not once per rendered frame.
# Anything that moves a physics body belongs here so the physics engine sees each movement.
# That matters for this node: AnimatableBody3D has sync_to_physics ON by default, which lets the
# physics engine estimate the car's velocity from how it moves, and that is what carries a player
# standing on it.
# `delta` = seconds since the previous physics tick (about 0.0167 at 60 ticks per second).
# Godot runs a parent's _physics_process before its children's, so by the time this runs the
# PathFollow3D has already moved this tick and `path_follow.progress` is up to date.
func _physics_process(delta: float) -> void:
	# ---- STEP 1: measure the car's real speed ----
	# speed = distance travelled / time taken. `progress` is measured in metres along the track,
	# so this comes out in metres per second. absf() is the absolute value: speed is never negative,
	# and the sideways push on a bend is the same whichever way the train is travelling.
	# We MEASURE speed instead of reading `trainSpeed` because follower cars do not have that
	# variable. This works identically for every car, and keeps working if speed later changes
	# through acceleration or braking.
	# KNOWN QUIRK: on a closed loop, the tick where progress wraps from the end of the track back
	# to 0 gives a difference of about the whole track length, so ONE tick reports a bogus speed
	# and the lean twitches slightly once per lap. If you want a challenge, look up wrapf():
	# wrapping the difference into the range (-half track length, +half track length) fixes it.
	var current_speed := absf(path_follow.progress - previous_progress) / delta
	previous_progress = path_follow.progress

	# ---- STEP 2: measure how sharply the track bends right here ----
	# We check which way the track points at the car's position and at a spot sample_offset metres
	# further along, and see how much the heading changed.
	# sample_offset = the distance in metres between those two spots.
	#   Too small: the curve is only stored as pre-computed points a fixed distance apart (see
	#              Curve3D's bake_interval), so tiny gaps give steppy, inaccurate answers.
	#   Too large: several bends blur into one average, and because we look AHEAD of the car's
	#              track point, the lean starts noticeably before the car reaches the bend.
	#   1.0 is a reasonable middle. Because of the division below, changing it does not change the
	#   size of the result, only how precise or how smoothed-out the measurement is.
	var sample_offset := 1.0

	# sample_baked_with_rotation(offset) asks the curve: "at `offset` metres along you, what is
	# your position AND orientation?" It returns a Transform3D where origin = position,
	# basis.x = sideways, basis.y = up and basis.z = FORWARD (the direction the track is heading).
	# We only want the forward direction, `.basis.z`: a Vector3 of length 1.
	# Both results are in the Path3D's local space, so comparing them is valid.
	# NOTE: Godot's docs do not say whether an offset past the END of a closed curve wraps around or
	# gets clamped. If it clamps, then during the last metre before the loop's seam forward_ahead
	# equals forward_here and the track reads as "straight" for a moment. If you ever see a lean
	# hiccup at the seam, wrapping the offset with fposmod(offset, track_curve.get_baked_length())
	# is the thing to try.
	var forward_here := track_curve.sample_baked_with_rotation(path_follow.progress).basis.z
	var forward_ahead := track_curve.sample_baked_with_rotation(path_follow.progress + sample_offset).basis.z

	# The angle between the two headings, in RADIANS (not degrees): how much the track turned over
	# sample_offset metres. signed_angle_to(to, axis) measures rotation around `axis`. Using
	# Vector3.UP means we only measure turning left or right, not climbing or dipping: hills do
	# not push a train sideways. Positive = counter-clockwise seen from above = a LEFT-hand bend,
	# negative = right-hand bend. Straight track = 0.
	# (Vector3.UP is the Path3D's own local up, so tilting the Path3D node sideways would tilt this.)
	var turn_angle := forward_here.signed_angle_to(forward_ahead, Vector3.UP)

	# Angle turned per metre travelled = curvature, in radians per metre. For a circular bend this
	# equals 1 / radius (0.02 means a 50 m radius). Dividing by sample_offset is what makes the
	# result independent of the sample distance. The sign (left positive, right negative) is kept.
	var curvature := turn_angle / sample_offset

	# ---- STEP 3: work out the lean that would cancel the sideways push ----
	# The formula from the top of the file. atan() turns the ratio "sideways push : gravity" into an
	# angle in radians. The sign follows curvature, so left and right bends lean opposite ways.
	# Straight track (curvature 0) or standing still (speed 0) gives 0, meaning level.
	var ideal_bank := atan(current_speed * current_speed * curvature / gravity)
	# Cap it. clampf(value, min, max) forces value into the range min..max. deg_to_rad() converts
	# the degrees setting into radians, which is what all the maths here and `rotation` use.
	ideal_bank = clampf(ideal_bank, -deg_to_rad(max_bank_degrees), deg_to_rad(max_bank_degrees))

	# ---- STEP 4: ease toward the ideal lean instead of jumping to it ----
	# lerp(from, to, weight) returns the value `weight` of the way from `from` to `to`
	# (0 = stay put, 1 = arrive instantly). With weight = bank_smoothing * delta, every tick the
	# lean closes a small fraction of the REMAINING gap: fast while far away, slowing as it
	# arrives. Multiplying by delta keeps the feel the same if the physics tick rate changes.
	# clampf(..., 0, 1) is a guard: a huge bank_smoothing or a big lag spike (large delta) could
	# push the weight above 1, which would fling the lean PAST the target instead of onto it.
	current_bank = lerp(current_bank, ideal_bank, clampf(bank_smoothing * delta, 0.0, 1.0))

	# Apply the lean. `rotation` is this node's rotation relative to its PARENT (the PathFollow3D),
	# as three angles in radians. `.z` is the roll around the car's own Z axis, which runs along
	# the length of the car, so changing it tilts the car sideways. Only .z is touched: x and y
	# stay 0, so the car's facing and pitch still come entirely from the PathFollow3D.
	# DIRECTION CHECK: worked out on paper, this leans INTO the bend (left bend -> left side
	# dips), assuming the PathFollow3D's "Use Model Front" option is off, which is its default.
	# That is a calculation, not something tested in the running game. If cars lean OUT of bends
	# when you test, put a minus sign here:  rotation.z = -current_bank
	rotation.z = current_bank

# Auto-generated by Godot and does nothing. _process runs every RENDERED frame (the rate varies
# with your frame rate), unlike _physics_process which runs at a fixed rate. Nothing in this
# script needs that, so the whole function can be deleted. Godot also warns that `delta` is
# unused here; renaming it to `_delta` silences that warning.
# func _process(delta: float) -> void:
#	pass
