extends Button

func _on_button_down() -> void:
	GameStateManager.updategamestate(2)
