extends Camera2D

@onready var game_manager: Node = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.gamestateUpdated.connect(_on_gamestate_update)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("play"):
		GameManager.updateScore("add", 1000)
		GameManager.levels += 1

func _on_gamestate_update(new_gamestate_id: int):
	if (new_gamestate_id == 0):
		offset.y = 0
	elif (new_gamestate_id == 1):
		offset.y = 715
