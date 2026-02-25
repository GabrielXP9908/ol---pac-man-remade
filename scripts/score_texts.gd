extends Node

func _process(_delta: float) -> void:
	$highscore.set_text(str(GameManager.highscore))
	$score.set_text(str(GameManager.score))
