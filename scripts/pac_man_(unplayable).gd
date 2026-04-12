extends AnimatedSprite2D

@onready var label_3: Label = $Label3
@onready var timer: Timer = $Timer

var secret_presses := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (position.x >= 1300):
		position.x = -50
	
	if Input.is_action_just_pressed("secret"):
		secret_presses += 1
	
	if (Input.is_action_pressed("secret") and secret_presses>5 and OS.has_feature("pc")):
		position.y = get_global_mouse_position()[1]
	
	if (secret_presses==5):
		label_3.position.y = -8
		position.y = 500

func _on_timer_timeout() -> void:
	position.x += 25
