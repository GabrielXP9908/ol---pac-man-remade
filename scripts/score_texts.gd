extends Node

@onready var highscore: Label = $highscore
@onready var score: Label = $score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.highScoreUpdated.connect(_on_highscore_update)
	GameManager.scoreUpdated.connect(_on_score_update)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_highscore_update(new_highscore: int):
	highscore.set_text(str(new_highscore))

func _on_score_update(new_score: int):
	score.set_text(str(new_score))
