extends Control
var tween: Tween

@export var scroll_speed: float = 100.0  # Adjust speed as needed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	$AudioStreamPlayer2D.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:

	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_play_2_pressed() -> void:

	get_tree().change_scene_to_file("res://Scenes/CompareNumbers.tscn")

func _on_play_3_pressed() -> void:

	get_tree().change_scene_to_file("res://Scenes/OrderNumbers.tscn")

func _on_play_4_pressed() -> void:

	get_tree().change_scene_to_file("res://Scenes/ComposeNumbers.tscn")

func _on_exit_pressed() -> void:

	get_tree().quit()
	


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
