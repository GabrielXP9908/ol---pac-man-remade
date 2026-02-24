extends TileMapLayer


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#

func _on_teleporter_left_area_entered(area: Area2D) -> void:
	print(area)
	if (area.has_method("teleporter")):
		area.teleporter("left")


func _on_teleporter_right_area_entered(area: Area2D) -> void:
	print(area)
	if (area.has_method("teleporter")):
		area.teleporter("right")
