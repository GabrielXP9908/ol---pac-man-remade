extends AnimatedSprite2D


enum Type {
	small,
	large
}

@export var size: Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if size == Type.small:
		play("small")
	else:
		play("large")

func _on_point_area_entered(area: Area2D) -> void:
	if area.has_method("isPacManCoinCollector"):
		%AntiCampTimer.start(5)
		GameManager.coins += 1
		if size == Type.small:
			GameManager.score += 10
		else:
			GameManager.score += 50
			Frigthend()
		queue_free()


func Frigthend() -> void:
	if GameManager.levels_capped == 1:
		FT.start(6)
	elif GameManager.levels_capped == 2:
		FT.start(5)
	elif GameManager.levels_capped == 3:
		FT.start(4)
	elif GameManager.levels_capped > 3 and GameManager.levels_capped < 19:
		FT.start(6)
	elif GameManager.levels_capped == 19:
		FT.start(6)
