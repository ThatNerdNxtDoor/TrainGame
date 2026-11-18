extends CanvasLayer

@onready var inventory_panel: Panel = $InventoryPanel
@onready var grid_container: GridContainer = $InventoryPanel/CenterContainer/GridContainer

var inventory: Inventory
var slot_scene: PackedScene

var selected_slot_index = -1
var slot_uis = []

var current_drop_target: int = -1

@onready var drag_icon: TextureRect = $DragOverlay/DragIcon




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
	
	drag_icon.hide()
	
func _process(delta: float) -> void:
	
	update_drag_visual()
	
	# Only detect drop targets while dragging
	if drag_icon.visible:
		update_drop_target()


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
	for child in grid_container.get_children():
		child.queue_free()

	slot_uis.clear()

	for i in range(inventory.slots.size()):
		var slot_ui = slot_scene.instantiate()
		grid_container.add_child(slot_ui)

		slot_ui.slot_index = i
		slot_ui.slot_clicked.connect(_on_slot_clicked)
		slot_ui.slot_dropped.connect(_on_slot_dropped)

		slot_uis.append(slot_ui)
		
func _on_slot_clicked(clicked_index: int) -> void:
	if selected_slot_index == -1:
		# Select an occupied slot.
		if inventory.slots[clicked_index].is_empty():
			return
			
		selected_slot_index = clicked_index

	else:
		# Move or swap the selected item.
		inventory.swap_slots(selected_slot_index, clicked_index)
		selected_slot_index = -1

	update_selection()


func update_selection() -> void:
	for i in range(slot_uis.size()):
		slot_uis[i].set_selected(i == selected_slot_index)


func update_inventory() -> void:
	for i in range(inventory.slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		var slot_ui = slot_uis[i]
		
		slot_ui.set_slot(inventory_slot)
		
	update_selection()
	
func _on_slot_dropped(source_index: int, target_index: int) -> void:
	
	# Clear the current selection
	selected_slot_index = -1
	
	# Make sure the source slot is valid.
	if source_index < 0 or source_index >= inventory.slots.size():
		return
		
	# Make sure the target slot is valid
	if target_index < 0 or target_index >= inventory.slots.size():
		update_selection()
		return
		
	# Move or swap the items.
	if target_index >= 0 and target_index < inventory.slots.size():
		inventory.swap_slots(source_index, target_index)
	
	
	# Refresh the inventory and selection borders
	update_selection()
	update_inventory()
	
func start_drag_visual(item_texture: Texture2D) -> void:
	
	drag_icon.texture = item_texture
	drag_icon.size = Vector2(150, 150)
	drag_icon.show()
	
	drag_icon.position = get_viewport().get_mouse_position() - drag_icon.size / 2
	
func update_drag_visual() -> void:
	
	if drag_icon.visible:
		drag_icon.position = get_viewport().get_mouse_position() - drag_icon.size / 2
		
func stop_drag_visual() -> void:
	
	drag_icon.hide()
	drag_icon.texture = null
	
	# Remove the drag border
	if current_drop_target >= 0 and current_drop_target < slot_uis.size():
		slot_uis[current_drop_target].set_drop_target(false)
		
	current_drop_target = -1
	
func update_drop_target() -> void:
	
	var hovered_control = get_viewport().gui_get_hovered_control()
	var target_index: int = -1
	
	while hovered_control != null:
		
		if hovered_control is Panel and hovered_control.has_method("set_drop_target"):
			target_index = hovered_control.slot_index
			break
			
		hovered_control = hovered_control.get_parent()
		
	# Only update the borders if the target changed.
	if target_index == current_drop_target:
		return
		
	# Remove the previous highlight
	if current_drop_target >= 0 and current_drop_target < slot_uis.size():
		slot_uis[current_drop_target].set_drop_target(false)
		
	# Highlight the new target
	current_drop_target = target_index

	if current_drop_target >= 0 and current_drop_target < slot_uis.size():
		slot_uis[current_drop_target].set_drop_target(true)
	
	
