extends Node2D


func _process(_delta: float) -> void:
	var direction = GameManager.getpacmandirection()
	var tmp_position = GameManager.getpacmanposition()
	
	if (direction == 1):
		global_position.y = tmp_position[1] - 32
		global_position.x = tmp_position[0]
	elif (direction == 2):
		global_position.x = tmp_position[0] + 32
		global_position.y = tmp_position[1]
	elif (direction == 3):
		global_position.y = tmp_position[1] + 32
		global_position.x = tmp_position[0]
	elif (direction == 4):
		global_position.x = tmp_position[0] - 32
		global_position.y = tmp_position[1]
