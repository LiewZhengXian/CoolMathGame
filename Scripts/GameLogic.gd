# GameLogic.gd
extends Node

signal round_completed(score_earned)
signal operation_changed(new_operation)

# Card values and operations
var available_card_values = [-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var available_operations = ["+", "-", "×"]
var curr_ops_index = 2
var current_operation = "+"
var operation_label
var required_slots = 2  # Number of card slots needed

# Round management
var current_round = 0
var score = 0
var round_in_progress = false

# References
var card_slots = []
var player_hand
var card_manager
var main_scene

func _ready():
	# Get references to needed nodes
	operation_label = $"../UI/OperationLabel"
	player_hand = $"../PlayerHand"
	card_manager = $"../CardManager"
	main_scene = $".."
	
	card_slots = get_tree().get_nodes_in_group("card_slots")
	
	for slot in card_slots:
		slot.connect("card_placed", Callable(self, "_on_card_placed_in_slot"))
		slot.connect("card_removed", Callable(self, "_on_card_removed_from_slot"))
	
	# Start the first round
	start_new_round()

func start_new_round():
	current_round += 1
	round_in_progress = true
	
	# Reset card slots
	for slot in card_slots:
		if slot.card_reference != null:
			if slot.card_reference.get_node("Area2D/CollisionShape2D"):
				slot.card_reference.get_node("Area2D/CollisionShape2D").disabled = false
			slot.card_reference = null
		slot.card_in_slot = false
	
	# Deal new cards to player's hand
	deal_new_cards()
	
	# Set random operation for this round
	set_random_operation()

func deal_new_cards():
	# First, clear existing hand if needed
	var existing_cards = get_tree().get_nodes_in_group("cards")
	var occupied_card_slots = get_tree().get_nodes_in_group("card_slots")
	#for slot in occupied_card_slots:
		#if(slot.get_card_value()):
			#player_hand.player_hand.erase(slot.get_card_value())
			#var index = existing_cards.find(slot.get_card_value())  # Find index
			#if index != -1:  # Ensure the element exists before deleting
				#existing_cards[index].queue_free()  # Free the node
	#for card in existing_cards:
		#card.queue_free()
	
	# Create new card scene
	var card_scene = preload("res://Scenes/Card.tscn")
	#player_hand.player_hand.clear()
	
	# Deal 5 random cards
	for i in range(player_hand.HAND_COUNT-player_hand.player_hand.size()):
		var new_card = card_scene.instantiate()
		card_manager.add_child(new_card)
		new_card.name = "Card" + str(i)
		new_card.add_to_group("cards")
		
		# Set random card value
		var card_value = available_card_values[randi() % available_card_values.size()]
		new_card.set_value(card_value)
		
		# Connect signals
		card_manager.connect_card_signals(new_card)
		
		# Add card to hand
		player_hand.add_card_to_hand(new_card)

func set_random_operation():
	if curr_ops_index+1 == available_operations.size():
		curr_ops_index = 0
	else:
		curr_ops_index += 1
	current_operation = available_operations[curr_ops_index]
	operation_label.text = current_operation
	emit_signal("operation_changed", current_operation)

func check_if_round_complete():
	# Check if all required slots are filled
	var filled_slots = 0
	var slot1 
	var slot2
	if card_slots[0].card_in_slot and card_slots[0].card_reference != null:
		slot1 = card_slots[0].card_reference
		filled_slots += 1
	if card_slots[1].card_in_slot and card_slots[1].card_reference != null:
		slot2 = card_slots[1].card_reference
		filled_slots += 1
	#for slot in card_slots:
		#if slot.card_in_slot and slot.card_reference != null:
			#filled_slots += 1
	
	if filled_slots >= required_slots:
		calculate_score()
		# Wait a moment before starting next round
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(func(): start_new_round())
		player_hand.player_hand.erase(slot1)
		player_hand.player_hand.erase(slot2)
		var existing_cards = get_tree().get_nodes_in_group("cards")
		for card in existing_cards:
			if card == slot1 || card == slot2:
				card.queue_free()
		round_in_progress = false

func calculate_score():
	$"../ScoreSound".play()
	var slot_values = []
	
	# Get values from filled slots
	for slot in card_slots:
		if slot.card_in_slot and slot.card_reference != null:
			slot_values.append(slot.card_reference.value)
	
	# Calculate based on current operation
	var result = slot_values[0]
	for i in range(1, slot_values.size()):
		match current_operation:
			"+":
				result += slot_values[i]
			"-":
				result -= slot_values[i]
			"×":
				result *= slot_values[i]
	
	# Update score
	var score_earned = result
	
	score += score_earned
	main_scene.update_score(score)
	
	emit_signal("round_completed", score_earned)
	
	# Show score animation
	show_score_popup(score_earned)

func show_score_popup(points):
	var popup = Label.new()
	if (points > 0):
	
		popup.text = "+" + str(points)
		popup.add_theme_font_size_override("font_size", 60)
		popup.modulate = Color(0, 1, 0)  # Green color
	else:
		popup.text =  str(points)
		popup.add_theme_font_size_override("font_size", 60)
		popup.modulate = Color(1, 0, 0)  # Red color
	
	# Position in center of screen
	var screen_size = get_viewport().size
	popup.position = Vector2(screen_size.x / 2, screen_size.y / 2)
	
	add_child(popup)
	
	# Animate the popup
	var tween = get_tree().create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 200, 1.0)
	tween.tween_property(popup, "modulate:a", 0.0, 0.5)
	tween.tween_callback(popup.queue_free)

func _on_card_placed_in_slot(_slot):
	check_if_round_complete()

func _on_card_removed_from_slot(_slot):
	# Handle if a card is removed from a slot
	pass

func _on_Home_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
