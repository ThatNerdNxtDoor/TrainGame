class_name InventorySlot
extends Resource


# ============================================================
# SLOT DATA
# ============================================================

# The item currently occupying this slot
var item: ItemData = null

# How many of that item are in the slot
var quantity: int = 0


# ============================================================
# CHECK IF EMPTY
# ============================================================

func is_empty() -> bool:

	return item == null or quantity <= 0


# ============================================================
# CHECK IF FULL
# ============================================================

func is_full() -> bool:

	if item == null:
		return false

	return quantity >= item.max_stack


# ============================================================
# CHECK IF ITEM CAN BE ADDED
# ============================================================

func can_add_item(new_item: ItemData) -> bool:

	# Empty slots can accept any item
	if is_empty():
		return true

	# Occupied slots can only accept the same item
	if item.item_id == new_item.item_id and not is_full():
		return true

	return false
