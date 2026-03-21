extends TextureButton

func _on_button_down() -> void:
	GameStateManager.updategamestate(2)
