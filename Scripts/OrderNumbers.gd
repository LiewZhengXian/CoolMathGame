extends Node2D

var numbers = []
var is_ascending = true
var score = 0
var questions_asked = 0
var number_boxes = []
var selected_box = null

func _ready():
	randomize()
	#$HomeButton.connect("pressed", self, "_on_Home_pressed")
	#$CheckButton.connect("pressed", self, "_on_Check_pressed")
	#$NextButton.connect("pressed", self, "_on_Next_pressed")
	#$AscendingButton.connect("pressed", self, "_on_Ascending_pressed")
	#$DescendingButton.connect("pressed", self, "_on_Descending_pressed")
	$AudioStreamPlayer2D.play()
	$NextButton.hide()
	$ResultLabel.hide()


	# Get references to number boxes
	for i in range(5):
		number_boxes.append(get_node("HBoxContainer/NumberBox" + str(i)))

		number_boxes[i].mouse_filter = Control.MOUSE_FILTER_STOP  
		number_boxes[i].connect("gui_input", Callable(self, "_on_box_input").bind(i))
		#number_boxes[i].connect("gui_input", self, "_on_box_input", [i])

	generate_question()
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Show a confirmation dialog instead of immediately quitting
		var confirm_dialog = ConfirmationDialog.new()
		confirm_dialog.dialog_text = "Are you sure you want to exit?"
		confirm_dialog.get_ok_button().text = "Yes"
		confirm_dialog.get_cancel_button().text = "No"
		confirm_dialog.connect("confirmed", Callable(self, "_on_quit_confirmed"))

		add_child(confirm_dialog)  # Ensure it's added to the scene

		confirm_dialog.call_deferred("popup_centered")  # Ensures it appears correctly

func _on_quit_confirmed():
	# User confirmed they want to quit
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
func generate_question():

	# Generate 5 random unique numbers
	numbers = []
	for i in range(5):
		var num = randi() % 99 + 1
		while num in numbers:
			num = randi() % 99 + 1
		numbers.append(num)
	
	# Randomly determine if ascending or descending
	is_ascending = (randi() % 2) == 0
	
	if is_ascending:

		$OrderLabel.text = "Swap these numbers \n into ASCENDING order \n (smallest to largest)"
		await get_tree().process_frame
		$OrderLabel.position.x = (1080 - $OrderLabel.size.x)/2
	else:
	
		$OrderLabel.text = "Swap these numbers \n in DESCENDING order \n (largest to smallest)"
		await get_tree().process_frame
		$OrderLabel.position.x = (1080 - $OrderLabel.size.x)/2
	
	# Update UI with numbers in random order
	for i in range(5):
		number_boxes[i].text = str(numbers[i])
	
	$ResultLabel.text = ""
	$CheckButton.disabled = false
	$NextButton.hide()

func _on_box_input(event, box_index):

	if  event is InputEventMouseButton and event.pressed:
		if selected_box == null:
			selected_box = box_index
			number_boxes[box_index].modulate = Color(1.5, 2, 1.5 , 1 )  # Highlight
		else:
			# Swap numbers
			var temp = number_boxes[selected_box].text
			number_boxes[selected_box].text = number_boxes[box_index].text
			number_boxes[box_index].text = temp
			
			# Reset selection
			number_boxes[selected_box].modulate = Color(1, 1, 1)
			selected_box = null
func _center_text(width):
	var viewport_width = get_viewport_rect().size.x
	$ResultLabel.position.x = (viewport_width-width) / 2
func _on_Check_pressed():
	questions_asked += 1
	
	# Get current order
	var current_order = []
	for i in range(5):
		current_order.append(int(number_boxes[i].text))
	
	# Check if order is correct
	var is_correct = true
	if is_ascending:
		for i in range(4):
			if current_order[i] > current_order[i+1]:
				is_correct = false
				break
	else:
		for i in range(4):
			if current_order[i] < current_order[i+1]:
				is_correct = false
				break
	
	if is_correct:

		$ResultLabel.label_settings.font_color = Color(0,1,0)
		$ResultLabel.text = "Correct! The numbers are in the right order."
		_center_text($ResultLabel.size.x)
		$ResultLabel.show()
		score += 1
	else:

		$ResultLabel.label_settings.font_color = Color(1,0,0)
		$ResultLabel.text = "Wrong! The numbers are not in the right order."
		_center_text($ResultLabel.size.x)
		$ResultLabel.show()
	
	$CheckButton.disabled = true
	$NextButton.show()
	update_score()



func update_score():
	$ScoreLabel.text = "Score: " + str(score) + "/" + str(questions_asked)

func _on_Next_pressed():
	$ResultLabel.hide()
	generate_question()

func _on_HomeButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
