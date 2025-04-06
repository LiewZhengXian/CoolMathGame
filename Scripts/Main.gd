# Main.gd
extends Node2D

# References to nodes
var score_label
var timer_label
var operation_label
var game_timer
var game_logic

# Game variables
var score = 0
var game_time = 60  # Game duration in seconds
var game_active = false

func _ready():
	# Initialize randomizer
	randomize()
	$AudioStreamPlayer2D.play()
	# Get references
	score_label = $UI/ScoreLabel
	timer_label = $UI/TimerLabel
	operation_label = $UI/OperationLabel
	game_timer = $UI/GameTimer
	game_logic = $GameLogic

	# Set up UI
	score_label.text = "Score: 0"
	score_label.position.y = 50  # Add some top padding

	timer_label.text = "Time: " + str(game_time)
	timer_label.position.y = 50  # Add some top padding

	operation_label.text = "+"


	# Configure timer
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_GameTimer_timeout)

	# Connect signals from game logic
	game_logic.connect("round_completed", Callable(self, "_on_round_completed"))
	game_logic.connect("operation_changed", Callable(self, "_on_operation_changed"))

	# Start the game
	start_game()
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
func _process(delta):
	if game_active:
		# Update timer display
		var time_left = game_timer.time_left
		timer_label.text = "Time: " + str(int(time_left))

func start_game():
	# Reset score
	score = 0
	update_score(0)
	
	# Start the timer
	game_timer.start(game_time)
	game_active = true

func end_game():
	game_active = false
	var game_over_scene = preload("res://Scenes/GameOver.tscn")
	var game_over_instance = game_over_scene.instantiate()  # Create instance
	game_over_instance.set_meta("score", score)  # Store metadata
	get_tree().current_scene.queue_free()  # Remove current scene
	get_tree().root.add_child(game_over_instance)  # Add new scene


	# Show game over screen
	#get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

	
	# Create game over display
	#var game_over = Label.new()
	#game_over.text = "GAME OVER\nFinal Score: " + str(score) + "\nPress SPACE to restart"
	#game_over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#game_over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#game_over.add_theme_font_size_override("font_size", 72)
#
	## Position in center of screen
	#var screen_size = get_viewport().get_visible_rect().size
	#game_over.position = Vector2(screen_size.x / 2 - 300, screen_size.y / 2 - 100)
	#game_over.size = Vector2(600, 200)

	#add_child(game_over)

func _on_GameTimer_timeout():
	# Timer has run out
	end_game()

func update_score(new_score):
	score = new_score
	score_label.text = "Score: " + str(score)

func _on_round_completed(score_earned):
	# Optional: add time bonus for completing rounds
	#add_time(2)  # Add 2 seconds per round

	# Flash the score display
	var original_color = score_label.modulate
	score_label.modulate = Color(0, 1, 0)  # Green flash
	await get_tree().create_timer(0.3).timeout
	score_label.modulate = original_color

func _on_operation_changed(new_operation):
	operation_label.text = new_operation

# Function to add time (bonus for completing rounds)
func add_time(seconds):
	if game_active:
		var current_time_left = game_timer.time_left
		game_timer.stop()
		game_timer.start(current_time_left + seconds)

func _input(event):
	# Handle restart game on space press when game over
	if not game_active and event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
# Reload the current scene to restart
			get_tree().reload_current_scene()

func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
