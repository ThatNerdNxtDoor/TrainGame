class_name ItemData
extends Resource


# ============================================================
# ITEM INFORMATION
# ============================================================

# Name displayed to the player
@export var item_name: String = "Item"

# Unique ID used to determine whether two items are the same
@export var item_id: String = ""

# Maximum number of this item that can occupy one slot
@export var max_stack: int = 1

# Item icon
# We don't need this yet, but it will be useful for the UI later.
@export var icon: Texture2D
