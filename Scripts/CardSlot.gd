#extends Node2D
##CardSlot
#var card_in_slot = false
#var card_reference 

extends Node2D

signal card_placed(slot)
signal card_removed(slot)

var card_in_slot = false
var card_reference = null
var slot_index = 0  # To identify which slot this is

func _ready():
	# Add to the card_slots group for easy access
	add_to_group("card_slots")

	# Set collision layer for detection
	$Area2D.collision_layer = 2  # CardManager.COLLISION_MASK_CARD_SLOT

func set_card(card):
	card_reference = card
	card_in_slot = true
	emit_signal("card_placed", self)

func clear_card():
	card_reference = null
	card_in_slot = false
	emit_signal("card_removed", self)

func get_card_value():
	if card_reference:
		return card_reference
	return 0
