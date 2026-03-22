extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = Vector2(GameManager.getpacmanposition())
	print(position)
