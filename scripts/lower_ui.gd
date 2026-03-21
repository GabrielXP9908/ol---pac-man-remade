extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Lives
	$lives.play(str(GameManager.lives))
	
	# Levels
	$levels.play(str(GameManager.levels_capped))
	
