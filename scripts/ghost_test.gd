extends CharacterBody2D

const speed = 3000

@export var Goal: Node = null

enum Ghost {
	Blinky,
	Pinky,
	Inky,
	Clyde
}

@export var GhostType : Ghost

# =============================
#           Richtungen
# 1 ---------- oben
# 2 ----------- rechts
# 3 ----------- unten
# 4 ----------- links
# =============================

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
	
	
	$AnimatedSprite2D.play(str(GhostType)+"_"+str(get_nav_direction()))
	
	#print(direction)
	#if (direction == 1):
		#$AnimatedSprite2D.play(str(GhostType)+"_"+"up")
	#elif (direction == 2):
		#$AnimatedSprite2D.play(str(GhostType)+"_"+"right")
		#print(str(GhostType)+"_"+"right")
	#elif (direction == 3):
		#$AnimatedSprite2D.play(str(GhostType)+"_"+"down")
	#elif (direction == 4):
		#$AnimatedSprite2D.play(str(GhostType)+"_"+"left")



func _on_timer_timeout() -> void:
	if $NavigationAgent2D.target_position != Goal.global_position:
		$NavigationAgent2D.target_position = Goal.global_position
		print("Recalculated")
	$Timer.start()
	print("new cycle")


func get_nav_direction() -> int:
	var dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	if abs(dir.x) > abs(dir.y):
		return 2 if dir.x > 0 else 4
	else:
		return 3 if dir.y > 0 else 1
