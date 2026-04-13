extends Button

func _on_button_down() -> void:
	Leaderboard.opened_from_menu = true
	GameStateManager.updategamestate(1)
