extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEV__exit_game"):
		if OS.has_feature("web"):
			print("Web version – not quitting")
		else:
			print("Scucess! Exiting because of User exit Input!")
			get_tree().quit(0)
