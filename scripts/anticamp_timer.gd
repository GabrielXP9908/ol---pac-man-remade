extends Timer

func _on_timeout() -> void:
	if GameManager.released_ghost < 4:
		GameManager.releaseNewGhostAsAntiCamp.emit()
		start()
