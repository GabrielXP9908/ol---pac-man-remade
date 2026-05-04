extends TileMapLayer


func _on_teleporter_left_area_entered(area: Area2D) -> void:
	if (area.has_method("teleporter")):
		print("area")
		area.teleporter("left")


func _on_teleporter_right_area_entered(area: Area2D) -> void:
	if (area.has_method("teleporter")):
		print("area")
		area.teleporter("right")


func _on_teleporter_left_body_entered(body: Node2D) -> void:
	if (body.has_method("teleporter")):
		print("body")
		body.teleporter("left")


func _on_teleporter_right_body_entered(body: Node2D) -> void:
	if (body.has_method("teleporter")):
		print("body")
		body.teleporter("right")
