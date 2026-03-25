extends CharacterBody2D

const speed = 1800
const debug = true

enum Ghost {
	Blinky,
	Pinky,
	Inky,
	Clyde
}

enum Phases {
	House,
	Hunt,
	Scatter,
	Frigthend
}

var Phase: Phases = Phases.House
var PacMan_in_Range = null

@export var Goal: Node = null
@export var GhostType : Ghost
@export var house_x: float
@export var house_y: float

# =============================
#           Richtungen
# 1 ---------- oben
# 2 ----------- rechts
# 3 ----------- unten
# 4 ----------- links
# =============================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# First Target
	$NavigationAgent2D.target_position = Goal.global_position
	
	# Event Connects
	GameManager.killPacMan.connect(on_pacman_death)
	
	# Debug Paths
	if debug:
		$NavigationAgent2D.debug_enabled = true
	else:
		$NavigationAgent2D.debug_enabled = false
	
	# Debug Path Colors
	if (GhostType == Ghost.Clyde):
		$NavigationAgent2D.debug_path_custom_color = Color(1.0, 0.494, 0.0, 1.0)  # Orange
	elif (GhostType == Ghost.Blinky):
		$NavigationAgent2D.debug_path_custom_color = Color(1.0, 0.0, 0.0, 1.0)
	elif (GhostType == Ghost.Pinky):
		$NavigationAgent2D.debug_path_custom_color = Color(1.0, 0.631, 0.675, 1.0)
	elif (GhostType == Ghost.Inky):
		$NavigationAgent2D.debug_path_custom_color = Color(0.0, 0.631, 0.835, 1.0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Blinky GameManager Position Update for Inky script
	if GhostType == Ghost.Blinky:
		GameManager.updateBlinkypos(global_position)
	
	# Navigation (Movement)
	if !$NavigationAgent2D.is_target_reached():
		var nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed * delta
		move_and_slide()
	
	# Animation Play
	$AnimatedSprite2D.play(str(GhostType)+"_"+str(get_nav_direction()))
	
	
	#region Phases
	#if (Phase == Phases.Scatter):
		#if (GhostType == Ghost.Clyde):
			#Goal = get_node("/root/Level/AI/NavPoints/Clyde/" + str(randi_range(1,10)))
	#elif (Phase == Phases.Hunt):
		#if (GhostType == Ghost.Clyde):
			#Goal = %NavPoints/PacManLocationTracker
			
		#==============
		#Moved to on timer timeout clyde specific
		#==============
	#endregion

# Recalculate Navigation Paths
func _on_timer_timeout() -> void:
	if $NavigationAgent2D.target_position != Goal.global_position:
		$NavigationAgent2D.target_position = Goal.global_position
	$Timer.start()

# Direction to go to
func get_nav_direction() -> int:
	var dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	if abs(dir.x) > abs(dir.y):
		return 2 if dir.x > 0 else 4
	else:
		return 3 if dir.y > 0 else 1

# PacMan Kill Collidor
func _on_kill_collidor_area_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.has_method("isPacMan"):
		GameManager.PacManDieNow()

# PacMan Death event
func on_pacman_death():
	position.x = 200000
	await get_tree().create_timer(1.3).timeout
	position.x = house_x
	position.y = house_y

# CLYDE ONLY!!!
# Check if in Range for States
func _on_check_timer_timeout() -> void:
	$CheckTimer.start()
	
	if PacMan_in_Range:
		Phase = Phases.Scatter
	else:
		Phase = Phases.Hunt
	
	if (Phase == Phases.Scatter):
		if (GhostType == Ghost.Clyde):
			Goal = get_node("/root/Level/AI/NavPoints/Clyde/" + str(randi_range(1,10)))
	elif (Phase == Phases.Hunt):
		if (GhostType == Ghost.Clyde):
			Goal = %NavPoints/PacManLocationTracker

# CLYDE ONLY
# Update if in Circle
func _on_inner_circle_area_entered(area: Area2D) -> void:
	if area.has_method("isPacMan") and GhostType == Ghost.Clyde:
		PacMan_in_Range = true
func _on_outer_circle_area_exited(area: Area2D) -> void:
	if area.has_method("isPacMan") and GhostType == Ghost.Clyde:
		PacMan_in_Range = false

# Map Teleporters
func teleporter(entered_map_side: String):
	if (entered_map_side == "left"):
		position = Vector2(400, 154)
	elif (entered_map_side == "right"):
		position = Vector2(175, 154)
	else:
		print("Error in pac_man.gd/func teleporter")
		print(entered_map_side + "is not a valid side input!")
		print("Valid ones are 'left', 'right'")
	print("===========================")
	print("===== Ghost Teleported ====")
	print("===========================")
	print("===== Start side: " + str(entered_map_side) + " =====")
	print("===========================")
	print("======Ghost: " + str(GhostType) + " =====")
	print("===========================")
