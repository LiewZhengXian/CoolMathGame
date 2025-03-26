extends Node2D

var number1 = 0
var number2 = 0
var correct_answer = ""
var score = 0
var questions_asked = 0
const MAX_ROUND = 10
var i = 1
func _ready():

	randomize()
	$AudioStreamPlayer2D.play()
	$UI/NextButton.hide()
	$UI/ResultLabel.hide()

	generate_question()

# Add this to your main_menu.gd script

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
	#if (i > MAX_ROUND):
		#get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	#i+=1
	# Generate two random numbers between 1 and 999
	number1 = randi() % 99 + 1
	number2 = randi() % 99 + 1

	# Ensure numbers are different
	while number1 == number2:
		number2 = randi() % 99 + 1

	# Determine correct answer
	if number1 < number2:
		correct_answer = "less than"
	else:
		correct_answer = "greater than"

	# Update UI
	$UI/Number1Label.text = str(number1)
	$UI/Number2Label.text = str(number2)
	$UI/ResultLabel.text = ""
	$UI/LessThanButton.disabled = false
	$UI/GreaterThanButton.disabled = false
	$UI/NextButton.hide()
func _center_text( width):
	var viewport_width = get_viewport_rect().size.x
	$UI/ResultLabel.position.x = (viewport_width-width) / 2
func _on_LessThan_pressed():
	questions_asked += 1
	if number1 < number2:
		$UI/ResultLabel.label_settings.font_color = Color(0,1,0)
		$UI/ResultLabel.text = "Correct! " + str(number1) + " is less than " + str(number2)
		_center_text($UI/ResultLabel.size.x)
		$UI/ResultLabel.show()

		score += 1
	else:
		$UI/ResultLabel.label_settings.font_color = Color(1,0,0)
		#$UI/ResultLabel.set("theme_override_colors/font_color", Color(1,0,0))
		$UI/ResultLabel.text = "Wrong! " + str(number1) + " is not less than " + str(number2)
		_center_text($UI/ResultLabel.size.x)
		$UI/ResultLabel.show()

	$UI/LessThanButton.disabled = true
	$UI/GreaterThanButton.disabled = true
	$UI/NextButton.show()
	update_score()

func _on_GreaterThan_pressed():
	questions_asked += 1
	if number1 > number2:

		$UI/ResultLabel.label_settings.font_color = Color(0,1,0)
		#$UI/ResultLabel.set("theme_override_colors/font_color", Color(1,0,0))
		$UI/ResultLabel.text = "Correct! " + str(number1) + " is greater than " + str(number2)
		_center_text($UI/ResultLabel.size.x)
		$UI/ResultLabel.show()

		score += 1
	else:

		$UI/ResultLabel.label_settings.font_color = Color(1,0,0)
		$UI/ResultLabel.text = "Wrong! " + str(number1) + " is not greater than " + str(number2)
		_center_text($UI/ResultLabel.size.x)
		$UI/ResultLabel.show()

	$UI/LessThanButton.disabled = true
	$UI/GreaterThanButton.disabled = true
	$UI/NextButton.show()
	update_score()

func update_score():
	$UI/ScoreLabel.text = "Score: " + str(score) + "/" + str(questions_asked)

func _on_Next_pressed():
	$UI/ResultLabel.hide()
	generate_question()

func _on_Home_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_audio_stream_player_2d_finished() -> void:

	$AudioStreamPlayer2D.play()
