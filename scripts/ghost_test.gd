extends CharacterBody2D

const speed = 6000

@export var Goal: Node = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NavigationAgent2D.target_position = Goal.global_position
	print(Goal.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$NavigationAgent2D.is_target_reached():
		var nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed * delta
		move_and_slide()



func _on_timer_timeout() -> void:
	if $NavigationAgent2D.target_position != Goal.global_position:
		$NavigationAgent2D.target_position = Goal.global_position
		print("Recalculated")
	$Timer.start()
	print("new cycle")
