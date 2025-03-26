extends VBoxContainer
var tween: Tween

func _ready() -> void:
	# Hide the label initially
	modulate.a = 0
	
	# Start the title animation
	animate_title()

func animate_title() -> void:
	# Create a new tween
	tween = create_tween()
	
	# Set up a sequence of animations
	tween.set_parallel(false)
	

	
	# Simultaneously fade in
	tween.tween_property(self, "modulate:a", 1.0, 1.05)
	
	# Scale and bounce effect
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Return to original scale
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Optional: Add a subtle rotation for more dynamism
	tween.tween_property(self, "rotation", 0.1, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "rotation", 0, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

# Optional: Method to restart animation
func restart_animation() -> void:
	animate_title()
