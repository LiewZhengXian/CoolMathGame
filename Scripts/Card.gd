extends Node2D
signal hovered
signal hovered_off

var starting_position = Vector2.ZERO
# Called when the node enters the scene tree for the first time.

var value = 0  # Numeric value of the card
var card_label  # Reference to the Label node for displaying value
func _ready():
	#get_parent().connect_card_signals(self)
	# Get reference to the label
	card_label = $CardValue
	# Set a default value if needed
	if value == 0:
		set_value(randi() % 10 + 1)  # Random value 1-10
	# Set collision layer
	$Area2D.collision_layer = 1  # CardManager.COLLISION_MASK_CARD

func set_value(new_value):
	value = new_value
	# Update the visual representation
	if card_label:
		card_label.text = str(value)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)
	print("hovered")



func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
