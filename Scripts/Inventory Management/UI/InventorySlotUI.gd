extends Panel


# Get the item icon texture rectangle
@onready var item_icon: TextureRect = $ItemIcon

# Get the quantity label
@onready var quantity_label: Label = $QuantityLabel

# Get the name label
@onready var item_name_label: Label = $ItemNameLabel

func set_slot(slot: InventorySlot) -> void:
	
	# Empty slot
	if slot.is_empty():
		item_icon.texture = null
		quantity_label.text = ""
		return
		
	# Item icon
	item_icon.texture = slot.item.icon
	
	# Item quantity
	quantity_label.text = str(slot.quantity)
	
	# Item name
	item_name_label.text = slot.item.item_name
