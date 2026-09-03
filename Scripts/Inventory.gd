class_name Inventory
extends Node


# ============================================================
# INVENTORY SETTINGS
# ============================================================

# Number of inventory slots
@export var slot_count: int = 20


# ============================================================
# INVENTORY DATA
# ============================================================

# Array containing all inventory slots
var slots: Array[InventorySlot] = []


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Create all inventory slots
	for i in range(slot_count):

		var slot: InventorySlot = InventorySlot.new()

		slots.append(slot)


# ============================================================
# ADD ITEM
# ============================================================

func add_item(item: ItemData, amount: int) -> int:

	# Make sure we aren't trying to add an invalid amount
	if amount <= 0:
		return 0

	# Make sure the item is valid
	if item == null:
		return amount

	# Keep track of how many items still need to be added
	var remaining: int = amount


	# ========================================================
	# FIRST: FILL EXISTING STACKS
	# ========================================================

	for slot: InventorySlot in slots:

		# Skip slots that contain a different item
		if slot.item != item:
			continue

		# Skip stacks that are already full
		if slot.is_full():
			continue


		# Determine how much room remains in this stack
		var space_available: int = item.max_stack - slot.quantity


		# Determine how much we can actually add
		var amount_to_add: int = min(
			space_available,
			remaining
		)


		# Add items to the stack
		slot.quantity += amount_to_add


		# Remove those items from the remaining amount
		remaining -= amount_to_add


		# Everything was added
		if remaining <= 0:

			return 0


	# ========================================================
	# SECOND: FIND EMPTY SLOTS
	# ========================================================

	for slot: InventorySlot in slots:

		# Skip slots that aren't empty
		if not slot.is_empty():
			continue


		# Put the item into the empty slot
		slot.item = item


		# Determine how much can fit
		var amount_to_add: int = min(
			item.max_stack,
			remaining
		)


		# Set the stack size
		slot.quantity = amount_to_add


		# Remove those items from the remaining amount
		remaining -= amount_to_add


		# Everything was added
		if remaining <= 0:

			return 0


	# ========================================================
	# INVENTORY FULL
	# ========================================================

	# Return anything that couldn't fit
	return remaining


# ============================================================
# REMOVE ITEM
# ============================================================

func remove_item(item: ItemData, amount: int) -> int:

	# Make sure we aren't trying to remove an invalid amount
	if amount <= 0:
		return 0

	# Make sure the item is valid
	if item == null:
		return amount


	# Keep track of how many items still need to be removed
	var remaining: int = amount


	# ========================================================
	# SEARCH THROUGH INVENTORY
	# ========================================================

	for slot: InventorySlot in slots:

		# Ignore slots containing a different item
		if slot.item != item:
			continue


		# Determine how much can be removed from this stack
		var amount_to_remove: int = min(
			slot.quantity,
			remaining
		)


		# Remove items
		slot.quantity -= amount_to_remove


		# Update remaining amount
		remaining -= amount_to_remove


		# ====================================================
		# EMPTY SLOT
		# ====================================================

		if slot.quantity <= 0:

			slot.item = null
			slot.quantity = 0


		# Everything was removed
		if remaining <= 0:

			return 0


	# ========================================================
	# NOT ENOUGH ITEMS
	# ========================================================

	# Return however many items we couldn't remove
	return remaining


# ============================================================
# GET ITEM COUNT
# ============================================================

func get_item_count(item: ItemData) -> int:

	if item == null:
		return 0


	var total: int = 0


	for slot: InventorySlot in slots:

		if slot.item == item:

			total += slot.quantity


	return total


# ============================================================
# CHECK IF PLAYER HAS ENOUGH ITEMS
# ============================================================

func has_item(item: ItemData, amount: int = 1) -> bool:

	return get_item_count(item) >= amount


# ============================================================
# CLEAR INVENTORY
# ============================================================

func clear_inventory() -> void:

	for slot: InventorySlot in slots:

		slot.item = null
		slot.quantity = 0
