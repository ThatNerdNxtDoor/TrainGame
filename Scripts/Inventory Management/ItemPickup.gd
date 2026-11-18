extends Area3D


# ============================================================
# ITEM INFORMATION
# ============================================================

@export var item: ItemData
@export var amount: int = 1

@export var promptYes: bool = true


# ============================================================
# PLAYER DETECTION
# ============================================================

var player_in_range := false
var player = null


# ============================================================
# PROMPT
# ============================================================

@onready var interaction_prompt = $InteractionPrompt


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	
	#Hide the prompt until the player gets close
	interaction_prompt.visible = false


# ============================================================
# PROCESS
# ============================================================

func _process(_delta: float) -> void:

	# Only check for interaction if the player is nearby
	if player_in_range:
		
		if promptYes:
			if Input.is_action_just_pressed("interact"):

				pick_up_item()
				
		else:
			pick_up_item()


# ============================================================
# PLAYER ENTERED AREA
# ============================================================

func _on_body_entered(body: Node3D) -> void:

	# Make sure this is the player
	if body.is_in_group("player"):

		player = body
		player_in_range = true

		# Show interaction prompt
		interaction_prompt.visible = true


# ============================================================
# PLAYER LEFT AREA
# ============================================================

func _on_body_exited(body: Node3D) -> void:

	# Make sure the player leaving is the player we detected
	if body == player:

		player = null
		player_in_range = false

		# Hide interaction prompt
		interaction_prompt.visible = false


# ============================================================
# PICK UP ITEM
# ============================================================

func pick_up_item() -> void:

	# Make sure we have a player
	if player == null:
		return


	# Find the player's inventory
	var inventory = player.get_node("Inventory")


	# Try to add the item
	var remaining = inventory.add_item(
		item,
		amount
	)
	
	inventory.print_inventory()
	
	print("Picked up: ", item.item_name, " x", amount)
	print("Total Scrap in inventory: ", inventory.get_item_count(item))


	# ========================================================
	# EVERYTHING FIT
	# ========================================================

	if remaining <= 0:

		# Remove the pickup from the world
		queue_free()


	# ========================================================
	# ONLY SOME FIT
	# ========================================================

	else:

		# Keep the amount that couldn't fit
		amount = remaining
