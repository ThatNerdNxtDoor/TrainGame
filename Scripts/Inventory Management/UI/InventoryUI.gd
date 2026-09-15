extends CanvasLayer

@onready var inventory_panel: Panel = $InventoryPanel
@onready var grid_container: GridContainer = $InventoryPanel/CenterContainer/GridContainer

var inventory: Inventory
var slot_scene: PackedScene


func _ready() -> void:

	# Start with the inventory hidden
	inventory_panel.visible = false
	
	# Find the player's Inventory node
	inventory = get_parent().get_node("Inventory")
	
	# Connect the signal
	inventory.inventory_changed.connect(update_inventory)

	# Load the inventory slot scene
	slot_scene = preload("res://Scenes/UI/InventorSlotUI.tscn")

	# Create the inventory slots
	create_slots()


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("inventory"):

		# Toggle inventory
		inventory_panel.visible = not inventory_panel.visible

		# Inventory opened
		if inventory_panel.visible:

			# Show the mouse
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

			# Update inventory contents
			update_inventory()

		# Inventory closed
		else:

			# Capture the mouse again
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func create_slots() -> void:

	# Remove any existing slots
	for child in grid_container.get_children():
		child.queue_free()

	# Create one UI slot for every inventory slot
	for i in range(inventory.slots.size()):

		var slot_ui = slot_scene.instantiate()

		grid_container.add_child(slot_ui)


func update_inventory() -> void:

	var ui_slots = grid_container.get_children()

	for i in range(inventory.slots.size()):

		var inventory_slot: InventorySlot = inventory.slots[i]
		var slot_ui = ui_slots[i]

		slot_ui.set_slot(inventory_slot)
