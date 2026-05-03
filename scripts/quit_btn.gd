extends Button

func _ready() -> void:
	if OS.has_feature("web"):
		disabled = true
		tooltip_text = "You cant do this in the web version!"

func _on_button_down() -> void:
	get_tree().quit()
