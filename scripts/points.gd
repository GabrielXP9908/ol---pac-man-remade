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
		GameManager.coins += 1
		if size == Type.small:
			GameManager.score += 10
		else:
			GameManager.score += 50
		queue_free()
