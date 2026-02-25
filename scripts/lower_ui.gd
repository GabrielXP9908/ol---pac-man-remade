extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Lives
	if (GameManager.lives == 1):
		$lives.play("one")
	elif (GameManager.lives == 2):
		$lives.play("two")
	elif (GameManager.lives == 3):
		$lives.play("three")
	elif (GameManager.lives == 4):
		$lives.play("four")
	elif (GameManager.lives == 5):
		$lives.play("five")
	
	
	
	# Levels
	$levels.play(str(GameManager.levels_capped))
	
