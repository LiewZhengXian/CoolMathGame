extends Node2D

var target_number = 0
var score = 0
var questions_asked = 0
var first_number = ""
var second_number = ""
var current_input_field = "first" # Can be "first" or "second"
@onready var FirstNumberLabel = $Equation/FirstNumberLabel
@onready var SecondNumberLabel =$Equation/SecondNumberLabel
@onready var PlusSignLabel = $Equation/PlusSignLabel
@onready var SumLabel = $Equation/SumLabel
var tween:Tween
func _ready():
	randomize()
	$AudioStreamPlayer2D.play()
	$ResultLabel.hide()
	$ResultLabel.text =  "Please enter both number "
	_center_text($ResultLabel.size.x) 
	$NextButton.hide()
	var grid = $NumberContainer
	var button1 = $NumberContainer/Button1
	button1.pressed.connect(_on_number_pressed.bind(1))
	# Connect number buttons
	for i in range(2,10):
		var button = button1.duplicate()
		button.name = "Button" + str(i)
		button.text = str(i)  # Display number on button
		grid.add_child(button)
		button.pressed.connect(_on_number_pressed.bind(i))
		#get_node("Button" + str(i)).connect("pressed", self, "_on_number_pressed", [i])
	
	$ClearButton.connect("pressed",Callable(self, "_on_Clear_pressed"))
	$SwitchInputButton.connect("pressed", Callable(self, "_on_Switch_Input_pressed"))

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
func generate_question():
	# Generate a random target number between 5 and 20 (can adjust based on difficulty)
	target_number = randi() % 16 + 2
	var viewport_width = get_viewport_rect().size.x

	# Update UI
	$TargetLabel.text = "Make " + str(target_number) + " using two numbers"
	await get_tree().process_frame
	$TargetLabel.position.x = (viewport_width-$TargetLabel.size.x) / 2
	FirstNumberLabel.text = ""
	SecondNumberLabel.text = ""
	PlusSignLabel.text = "+"
	SumLabel.text = "="
	first_number = ""
	second_number = ""
	current_input_field = "first"
	highlight_current_field()

	$ResultLabel.text = ""
	$CheckButton.disabled = false
	$NextButton.hide()

func _on_number_pressed(digit):
	# Add the pressed digit to the current input field
	if current_input_field == "first":
		if len(first_number) < 1:  # Limit to 1 digits
			first_number += str(digit)
			FirstNumberLabel.text = first_number
	else:
		if len(second_number) < 1:  # Limit to 1 digits
			second_number += str(digit)
			SecondNumberLabel.text = second_number

	

func check_sum_display():
	# Show the current sum if both fields have numbers
	if first_number != "" and second_number != "":
		var sum_value = int(first_number) + int(second_number)
		SumLabel.text = "= " + str(sum_value)
	else:
		SumLabel.text = "="

func _on_Clear_pressed():
	# Clear the current input field
	if current_input_field == "first":
		first_number = ""
		FirstNumberLabel.text = ""
	else:
		second_number = ""
		SecondNumberLabel.text = ""
	
	check_sum_display()

func _on_Switch_Input_pressed():
	# Switch between input fields
	if current_input_field == "first":
		current_input_field = "second"
	else:
		current_input_field = "first"
	
	highlight_current_field()

func highlight_current_field():
	# Visually highlight which field is active
	if current_input_field == "first":
		FirstNumberLabel.modulate = Color(1, 1, 1)    # Normal
		SecondNumberLabel.modulate =  Color(1.5, 2, 1.5 , 1 )
		start_scale_animation(FirstNumberLabel)

	else:
		FirstNumberLabel.modulate = Color(1.5, 2, 1.5 , 1 ) 
		SecondNumberLabel.modulate = Color(1, 1, 1)   # Normal
		start_scale_animation(SecondNumberLabel)
func start_scale_animation(label) -> void:
	# Reset tween if it exists
	if tween:
		tween.kill()
	
	# Create a new tween
	tween = create_tween()
	
	# Make the tween loop continuously
	tween.set_loops()
	
	# Sequence of scaling animations
	# Scale up
	tween.tween_property(label, "scale", Vector2(1,1), 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Scale back to original size
	tween.tween_property(label, "scale", Vector2(1.05,1.05), 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_Check_pressed():

	# Check if both numbers are entered
	if first_number=="" or second_number=="":
		$ResultLabel.text = "Please enter both numbers!"
		await get_tree().process_frame
		$ResultLabel.label_settings.font_color = Color(0,0,0)
		_center_text($ResultLabel.size.x)
		$ResultLabel.show()
		return
	check_sum_display()
	questions_asked += 1
	var num1 = int(first_number)
	var num2 = int(second_number)
	var sum_value = num1 + num2

	if sum_value == target_number:


		$ResultLabel.label_settings.font_color = Color(0,1,0)
		$ResultLabel.text = "Correct! " + str(num1) + " + " + str(num2) + " = " + str(target_number)
		await get_tree().process_frame
		_center_text($ResultLabel.size.x)
		$ResultLabel.show()
		score += 1
	else:
		$ResultLabel.label_settings.font_color = Color(1,0,0)
		$ResultLabel.text = "Wrong! " + str(num1) + " + " + str(num2) + " = " + str(sum_value) + ", not " + str(target_number)
		await get_tree().process_frame
		_center_text($ResultLabel.size.x)
		$ResultLabel.show()

	$CheckButton.disabled = true
	$NextButton.show()
	update_score()
	
func _center_text(width):
	var viewport_width = get_viewport_rect().size.x
	$ResultLabel.position.x = (viewport_width-width) / 2
	
func update_score():
	$ScoreLabel.text = "Score: " + str(score) + "/" + str(questions_asked)

func _on_Next_pressed():
	$ResultLabel.hide()
	generate_question()

func _on_Home_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
