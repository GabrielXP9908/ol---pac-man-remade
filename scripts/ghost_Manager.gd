extends CharacterBody2D

const speed = 1700
const debug = true

enum Ghost {
	Blinky,
	Pinky,
	Inky,
	Clyde
}

enum Phases {
	Hunt,
	Scatter,
	Frigthend
}

var dead: bool = false

var home: bool = false

var Phase: Phases
var PacMan_in_Range = null

@export var Hunting_Goal: Node = null
var Goal
var Dead: bool

@onready var PT: Timer = $PhaseTimer

@export var GhostType : Ghost
@export var house_x: float
@export var house_y: float

var named_ghost: String

var hunt_timer: int = 0


# =============================
#           Richtungen
# 1 ---------- oben
# 2 ----------- rechts
# 3 ----------- unten
# 4 ----------- links
# =============================

var GisFREE: bool = false
var PhaseCounter: int = 0
var CFakeScatter: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Event Connects
	
	convertname()
	
	GameManager.killPacMan.connect(on_pacman_death)
	GameManager.releaseNewGhostAsAntiCamp.connect(force_release)
	
	# Debug Paths
	if debug:
		$NavigationAgent2D.debug_enabled = true
	else:
		$NavigationAgent2D.debug_enabled = false
	
	# Ghost Specific
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
	
	# Leave House Timings
	if (GhostType == Ghost.Clyde and !GisFREE):
		if GameManager.levels == 1 and GameManager.coins == 60:
			GisFREE = true
			GameManager.released_ghost += 1
			startPhaseTimer()
			#$NavigationAgent2D.target_position = Goal.global_position
		if GameManager.levels == 2 and GameManager.coins == 50:
			GisFREE = true
			GameManager.released_ghost += 1
			startPhaseTimer()
			#$NavigationAgent2D.target_position = Goal.global_position
		if GameManager.levels > 2:
			GisFREE = true
			GameManager.released_ghost += 1
			startPhaseTimer()
			#$NavigationAgent2D.target_position = Goal.global_position
	elif (GhostType == Ghost.Blinky and !GisFREE):
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()
		#$NavigationAgent2D.target_position = Goal.global_position
	elif (GhostType == Ghost.Pinky and !GisFREE):
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()
		#$NavigationAgent2D.target_position = Goal.global_position
	elif (GhostType == Ghost.Inky and !GisFREE):
		if GameManager.levels == 1 and GameManager.coins == 30:
			GisFREE = true
			GameManager.released_ghost += 1
			startPhaseTimer()
			#$NavigationAgent2D.target_position = Goal.global_position
		elif GameManager.levels > 1:
			GisFREE = true
			GameManager.released_ghost += 1
			startPhaseTimer()
			#$NavigationAgent2D.target_position = Goal.global_position

	#DEBUG!!!!!!!!!!!!!!!
	#print(str(GhostType) + " - " + str(Phase) + " - " + str(PhaseCounter))
	

	
	# Blinky GameManager Position Update for Inky script
	if GhostType == Ghost.Blinky:
		GameManager.updateBlinkypos(global_position)
	
	# Navigation (Movement)
	if !$NavigationAgent2D.is_target_reached():
		var nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed * delta
		move_and_slide()
	
	# Animation Play
	if Phase != Phases.Frigthend:
		$AnimatedSprite2D.play(str(GhostType)+"_"+str(get_nav_direction()))
	elif Phase == Phases.Frigthend:
		$AnimatedSprite2D.play("frigthend")
	elif dead:
		$AnimatedSprite2D.play("dead")

# Recalculate Navigation Paths
func _on_timer_timeout() -> void:
	if (Phase == Phases.Scatter):
		Goal = get_node("/root/Level/AI/NavPoints/" + named_ghost + "/" + str(randi_range(1,10)))
	elif (Phase == Phases.Hunt):
		Goal = Hunting_Goal
	
	
	
	if dead:
		Goal = get_node("/root/Level/AI/NavPoints/House")
		if home:
			dead = false
	
	if $NavigationAgent2D.target_position != Goal.global_position and GisFREE:
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
	if area.has_method("isPacMan") and !GameManager.frigthend:
		GameManager.PacManDieNow()
	elif area.has_method("isPacMan") and GameManager.frigthend:
		dead = true

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
	
	# CLADE ONLY FAKE SCATTER
	if PacMan_in_Range and GhostType == Ghost.Clyde and !CFakeScatter and GisFREE:
		Phase = Phases.Scatter
		CFakeScatter = true
	elif !PacMan_in_Range and GhostType == Ghost.Clyde and CFakeScatter and GisFREE:
		Phase = Phases.Hunt
		CFakeScatter = false
	

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

func startPhaseTimer() -> void:
	# LEVEL 1
	if GameManager.levels < 5 and PhaseCounter == 0:
		PT.start(7)
		Phase = Phases.Scatter
		CFakeScatter = false
	elif GameManager.levels > 4 and PhaseCounter == 0:
		PT.start(5)
		Phase = Phases.Scatter
		CFakeScatter = false
	
	# LEVEL 2
	if PhaseCounter == 1:
		PT.start(20)
		Phase = Phases.Hunt
	
	# LEVEL 3
	if PhaseCounter == 2:
		PT.start(7)
		Phase = Phases.Scatter
		CFakeScatter = false
	
	# LEVEL 4
	if PhaseCounter == 3:
		PT.start(20)
		Phase = Phases.Hunt
	
	# LEVEL 5
	if PhaseCounter == 4:
		PT.start(5)
		Phase = Phases.Scatter
		CFakeScatter = false
	
	# LEVEL 6
	if PhaseCounter == 5 and GameManager.levels == 1:
		PT.start(20)
		Phase = Phases.Hunt
	elif PhaseCounter == 4 and GameManager.levels != 1:
		PT.start(1033)
		Phase = Phases.Hunt
	
	# LEVEL 7
	if PhaseCounter == 6 and GameManager.levels == 1:
		PT.start(5)
		Phase = Phases.Scatter
		CFakeScatter = false
	elif PhaseCounter == 6 and GameManager.levels != 1:
		PT.start(0.1)
		Phase = Phases.Scatter
		CFakeScatter = false
	
	if PhaseCounter == 7:
		Phase = Phases.Hunt
	
	PhaseCounter += 1

func _on_phase_timer_timeout() -> void:
	startPhaseTimer()


func convertname() -> void:
	if GhostType == Ghost.Blinky:
		named_ghost = "Blinky"
	elif GhostType == Ghost.Pinky:
		named_ghost = "Pinky"
	elif GhostType == Ghost.Inky:
		named_ghost = "Inky"
	elif GhostType == Ghost.Clyde:
		named_ghost = "Clyde"


func force_release() -> void:
	# 1 = Blinky
	# 2 = Pinky
	# 3 = Inky
	# 4 = Clyde
	if GameManager.released_ghost == 0 and GhostType == Ghost.Blinky:
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()
	elif GameManager.released_ghost == 1 and GhostType == Ghost.Pinky:
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()
	elif GameManager.released_ghost == 2 and GhostType == Ghost.Inky:
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()
	elif GameManager.released_ghost == 3 and GhostType == Ghost.Clyde:
		GisFREE = true
		GameManager.released_ghost += 1
		startPhaseTimer()


func _on_respawn_body_entered(body: Node2D) -> void:
	home = true


func _on_respawn_body_exited(body: Node2D) -> void:
	home = false
