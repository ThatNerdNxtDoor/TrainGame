extends Panel


# Get the item icon texture rectangle
@onready var item_icon: TextureRect = $ItemIcon

# Get the quantity label
@onready var quantity_label: Label = $QuantityLabel

# Get the name label
@onready var item_name_label: Label = $ItemNameLabel

# Get the tolltip panel
@onready var tooltip_panel: PanelContainer = $TooltipPanel

# Get the tooltip text
@onready var tooltip_description: Label = $TooltipPanel/TooltipText


# Get the hover border
@onready var hover_border: Panel = $HoverBorder

# Get the selected border
@onready var selected_border: Panel = $SelectedBorder

# variable to handle if to right click for the tooltip or not
@export var right_click_tool_tip: bool = true

# Create a signal
signal slot_clicked(slot_ui: Control)

var slot_index: int = -1

var current_slot: InventorySlot = null

func _ready() -> void:
	
	# Hide the tool tip panel
	tooltip_panel.hide()
	
	# Hide the hover and selected border
	hover_border.hide()
	selected_border.hide()
	

func set_slot(slot: InventorySlot) -> void:
	
	# Set the current slot
	current_slot = slot
	
	# Empty slot
	if slot.is_empty():
		item_icon.texture = null
		quantity_label.text = ""
		item_name_label.text = ""
		tooltip_panel.hide()
		
		return
		
	# Item icon
	item_icon.texture = slot.item.icon
	
	# Item quantity
	quantity_label.text = str(slot.quantity)
	
	# Item name
	item_name_label.text = slot.item.item_name
	
	tooltip_description.text = slot.item.item_name + "\n" + slot.item.item_description
	
func set_selected(selected: bool) -> void:
	
	# Set the selected slot's border to selected
	selected_border.visible = selected
	
func _gui_input(event: InputEvent) -> void:
	
	# Check to ensure it is the mouse
	if event is InputEventMouseButton:
		
		# Validate that is is the left mouse that is clicked
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			# Emit the signal
			slot_clicked.emit(self)
			
			# Stop it from propogating to other nodes
			accept_event()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			
			if right_click_tool_tip:
				if hover_border.visible:
					hover_border.hide()
					tooltip_panel.hide()
					
				else:
					hover_border.show()
					tooltip_panel.show()

			
	
func _on_mouse_entered() -> void:
	
	# Check the slot
	if current_slot == null or current_slot.is_empty():
		return
		
	tooltip_description.text = current_slot.item.item_name + "\n" + current_slot.item.item_description
	
	if !right_click_tool_tip:
		tooltip_panel.show()
		
		hover_border.show()
	
	
	

func _on_mouse_exited() -> void:
	
	tooltip_panel.hide()
	
	hover_border.hide()
	
	
