extends Control
var highscore = 0
func _ready():
	highscore = load_highscore()
	if has_meta("score"):
		var score = get_meta("score")
		if (score > highscore):
			save_highscore(score)
			highscore = score
		
		$Score.text = "Score: " + str(score)
		$HighScore.text = "Highest Score: " + str(highscore)
		await get_tree().process_frame
		_center_text($Score.size.x)
		_center_text($HighScore.size.x)

func _center_text( width):
	var viewport_width = get_viewport_rect().size.x
	$Score.position.x = (viewport_width-width) / 2
func _center_text_highscore(width):
	var viewport_width = get_viewport_rect().size.x
	$HighScore.position.x = (viewport_width-width) / 2


func _on_back_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func save_highscore(score) -> void:
	var file = FileAccess.open("user://savefile.dat", FileAccess.WRITE)
	if file:  # Check if file was successfully opened
		file.store_32(score)
		file.close()
	else:
		printerr("Failed to open savefile.dat for writing!")

func load_highscore() -> int:
	if FileAccess.file_exists("user://savefile.dat"):
		var file = FileAccess.open("user://savefile.dat", FileAccess.READ)
		if file:  # Check if file was successfully opened
			var loaded_score = file.get_32()
			file.close()
			return loaded_score
		else:
			printerr("Failed to open savefile.dat for reading!")
			return 0  # Default highscore
	else:
		return 0  # No file exists, return default highscore
