extends Node2D

func _process(_delta: float) -> void:
	var direction = GameManager.getpacmandirection()
	var tmp_position = GameManager.getpacmanposition()
	var blinky_pos = GameManager.getblinkyposition()
	var tmp2_pos: Vector2
	
	if (direction == 1):
		tmp2_pos.y = tmp_position[1] - 16
		tmp2_pos.x = tmp_position[0]
	elif (direction == 2):
		tmp2_pos.x = tmp_position[0] + 16
		tmp2_pos.y = tmp_position[1]
	elif (direction == 3):
		tmp2_pos.y = tmp_position[1] + 16
		tmp2_pos.x = tmp_position[0]
	elif (direction == 4):
		tmp2_pos.x = tmp_position[0] - 16
		tmp2_pos.y = tmp_position[1]
	
	global_position = tmp2_pos + (tmp2_pos - blinky_pos)
	print(global_position)
