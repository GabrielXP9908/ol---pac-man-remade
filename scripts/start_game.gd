extends TextureButton

func _on_button_down() -> void:
	GameManager.updateGameState(1)
