extends Area2D

var colliding_up := true
var colliding_right := false
var colliding_down := true
var colliding_left := false

@onready var timer: Timer = $Timer


var allow_movement := false
var local_gamestate := 0

var store_one_input := 0 # 0 = _empty, 1 = up, 2 = right, 3 = down, 4 = up 
var direction := 0 # 0 = _empty, 1 = up, 2 = right, 3 = down, 4 = up 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStateManager.gamestateupdated.connect(_on_gamestate_update)
	GameManager.killPacMan.connect(die)
	GameManager.levels += 1
	GameManager.coins = 0
	
	if local_gamestate != GameStateManager.gamestate:
		GameStateManager.gamestateupdated.emit(GameStateManager.gamestate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	GameManager.positionupdate(position.x, position.y)
	
#region Debug
	#print("=== DEBUG ===")
	#print("Allow Movement: ", allow_movement)
	#print("Colliding Up:   ", colliding_up)
	#print("Colliding Right:", colliding_right)
	#print("Colliding Down: ", colliding_down)
	#print("Colliding Left: ", colliding_left)
	#print("=============")
#endregion

	#if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("right")):
		#print("test")
	if allow_movement:
		if (Input.is_action_just_pressed("up")):
			store_one_input = 1
		
		if (Input.is_action_just_pressed("right")):
			store_one_input = 2
		
		if (Input.is_action_just_pressed("down")):
			store_one_input = 3
		
		if (Input.is_action_just_pressed("left")):
			store_one_input = 4
	
#region stored to direction
	
	if (store_one_input != 0):
		if (store_one_input == 1):
			if (colliding_up):
				pass
			else:
				direction = 1
				$PacManSprite.play("up")
				store_one_input = 0
		elif (store_one_input == 2):
			if (colliding_right):
				pass
			else:
				direction = 2
				$PacManSprite.play("right")
				store_one_input = 0
		elif (store_one_input == 3):
			if (colliding_down):
				pass
			else:
				direction = 3
				$PacManSprite.play("down")
				store_one_input = 0
		elif (store_one_input == 4):
			if (colliding_left):
				pass
			else:
				direction = 4
				$PacManSprite.play("left")
				store_one_input = 0
	
	#print("--------------")
	#print(direction)
	#print("--------------")
	#print(store_one_input)
	#print("--------------")
#endregion


func isPacMan() -> bool:
	return true


func teleporter(entered_map_side: String):
	if (entered_map_side == "left"):
		direction = 4
		if (store_one_input == 0 or store_one_input == 1 or store_one_input == 3):
			pass
		else:
			store_one_input = 4
		position = Vector2(400, 154)
	elif (entered_map_side == "right"):
		direction = 2
		if (store_one_input == 0 or store_one_input == 1 or store_one_input == 3):
			pass
		else:
			store_one_input = 2
		position = Vector2(175, 154)
	else:
		print("Error in pac_man.gd/func teleporter")
		print(entered_map_side + "is not a valid side input!")
		print("Valid ones are 'left', 'right'")
	print(entered_map_side + str(direction) + str(store_one_input))


func _on_timer_timeout() -> void:
	timer.start()
	if (direction == 0):
		pass
	elif (direction == 1 and !colliding_up):
		position.y -= 1
	elif (direction == 2 and !colliding_right):
		position.x += 1
	elif (direction == 3 and !colliding_down):
		position.y += 1
	elif (direction == 4 and !colliding_left):
		position.x -= 1
	else:
		direction = 0
	#print(direction)
	#print(store_one_input)



func _on_gamestate_update(new_gamestate_id: int):
	if (new_gamestate_id != 2):
		timer.stop()
		allow_movement = false
	else:
		timer.start()
		allow_movement = true



func _on_collision_up_body_entered(_body: Node2D) -> void:
	colliding_up = true

func _on_collision_up_body_exited(_body: Node2D) -> void:
	colliding_up = false

func _on_collision_right_body_entered(_body: Node2D) -> void:
	colliding_right = true

func _on_collision_right_body_exited(_body: Node2D) -> void:
	colliding_right = false

func _on_collision_down_body_entered(_body: Node2D) -> void:
	colliding_down = true

func _on_collision_down_body_exited(_body: Node2D) -> void:
	colliding_down = false

func _on_collision_left_body_entered(_body: Node2D) -> void:
	colliding_left = true

func _on_collision_left_body_exited(_body: Node2D) -> void:
	colliding_left = false


#region Live System
func die():
	GameManager.lives -= 1
	allow_movement = false
	direction = 0
	store_one_input = 0
	$PacManSprite.play("death")
	await get_tree().create_timer(1.3).timeout
	if (GameManager.lives <= 0):
		GameManager.GameOver()
	else:
		position.x = 289
		position.y = 226
		allow_movement = true
		$PacManSprite.play("up")
#endregion
