extends CanvasLayer

@onready var inventory_panel: Panel = $InventoryPanel
@onready var grid_container: GridContainer = $InventoryPanel/CenterContainer/GridContainer

var inventory: Inventory
var slot_scene: PackedScene

var selected_slot_index = -1
var slot_uis = []


func _ready() -> void:

	# Start with the inventory hidden
	inventory_panel.visible = false
	
	# Find the player's Inventory node
	inventory = get_parent().get_node("Inventory")
	
	# Connect the signal
	inventory.inventory_changed.connect(update_inventory)

	# Load the inventory slot scene
	slot_scene = preload("res://Scenes/UI/InventorySlotUI.tscn")

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

	# Clear the current array
	slot_uis.clear()
	
	# Create one UI slot for every inventory slot
	for i in range(inventory.slots.size()):

		var slot_ui = slot_scene.instantiate()

		grid_container.add_child(slot_ui)
		
		# Set the slot index
		slot_ui.slot_index = i
		
		# Connect the slot_clicked signal
		slot_ui.slot_clicked.connect(_on_slot_clicked)
		
		# Append the slot
		slot_uis.append(slot_ui)
		
func _on_slot_clicked(slot_ui: Control) -> void:
	
	# Grab the index
	var clicked_index: int = slot_ui.slot_index

	# Handle invalid index
	if selected_slot_index == -1:
		
		# See if it is empty
		if inventory.slots[clicked_index].is_empty():
			return

		# Set the selected slot index
		selected_slot_index = clicked_index

	else:
		
		# Swap the slots
		inventory.swap_slots(selected_slot_index, clicked_index)
		selected_slot_index = -1

	update_selection()


func update_selection() -> void:
	for i in range(slot_uis.size()):
		slot_uis[i].set_selected(i == selected_slot_index)


func update_inventory() -> void:

	var ui_slots = grid_container.get_children()

	for i in range(inventory.slots.size()):

		var inventory_slot: InventorySlot = inventory.slots[i]
		var slot_ui = ui_slots[i]

		slot_ui.set_slot(inventory_slot)
