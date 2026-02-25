extends Area2D

@onready var collision_checker_down: RayCast2D = $CollisionCheckerDown
@onready var collision_checker_left: RayCast2D = $CollisionCheckerLeft
@onready var collision_checker_up: RayCast2D = $CollisionCheckerUp
@onready var collision_checker_right: RayCast2D = $CollisionCheckerRight

var colliding_up := true
var colliding_right := false
var colliding_down := true
var colliding_left := false

@onready var timer: Timer = $Timer

var store_one_input := 0 # 0 = _empty, 1 = up, 2 = right, 3 = down, 4 = up 
var direction := 0 # 0 = _empty, 1 = up, 2 = right, 3 = down, 4 = up 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.gamestateUpdated.connect(_on_gamestate_update)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("right")):
		#print("test")
	
	if (Input.is_action_just_pressed("up")):
		store_one_input = 1
	
	if (Input.is_action_just_pressed("right")):
		store_one_input = 2
	
	if (Input.is_action_just_pressed("down")):
		store_one_input = 3
	
	if (Input.is_action_just_pressed("left")):
		store_one_input = 4
	
	
#region stored -> direction
	if (store_one_input != 0):
		
		
		if (store_one_input == 1):
			if (collision_checker_up.is_colliding()):
				pass
			else:
				if (direction == 1):
					position.y -= 2.5
				elif (direction == 2):
					position.x += 2.5
				elif (direction == 3):
					position.y += 2.5
				elif (direction == 4):
					position.x -= 2.5
				else:
					print("Error!!!! at pac_man.gd/_process #1")
				direction = 1
				store_one_input = 0
		elif (store_one_input == 2):
			if (collision_checker_right.is_colliding()):
				pass
			else:
				if (direction == 1):
					position.y -= 2.5
				elif (direction == 2):
					position.x += 2.5
				elif (direction == 3):
					position.y += 2.5
				elif (direction == 4):
					position.x -= 2.5
				else:
					print("Error!!!! at pac_man.gd/_process #1")
				direction = 2
				store_one_input = 0
		elif (store_one_input == 3):
			if (collision_checker_down.is_colliding()):
				pass
			else:
				if (direction == 1):
					position.y -= 2.5
				elif (direction == 2):
					position.x += 2.5
				elif (direction == 3):
					position.y += 2.5
				elif (direction == 4):
					position.x -= 2.5
				else:
					print("Error!!!! at pac_man.gd/_process #1")
				direction = 3
				store_one_input = 0
		elif (store_one_input == 4):
			if (collision_checker_left.is_colliding()):
				pass
			else:
				if (direction == 1):
					position.y -= 2.5
				elif (direction == 2):
					position.x += 2.5
				elif (direction == 3):
					position.y += 2.5
				elif (direction == 4):
					position.x -= 2.5
				else:
					print("Error!!!! at pac_man.gd/_process #1")
				direction = 4
				store_one_input = 0
#endregion
	
	
	#print("--------------")
	#print(direction)
	#print("--------------")
	#print(store_one_input)
	#print("--------------")


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
	print("test")
	print(direction)
	print(store_one_input)



func _on_gamestate_update(new_gamestate_id: int):
	if (new_gamestate_id != 1):
		timer.stop()
	else:
		timer.start()






func _on_collision_up_body_entered(body: Node2D) -> void:
	colliding_up = true

func _on_collision_up_body_exited(body: Node2D) -> void:
	colliding_up = false

func _on_collision_right_body_entered(body: Node2D) -> void:
	colliding_right = true

func _on_collision_right_body_exited(body: Node2D) -> void:
	colliding_right = false

func _on_collision_down_body_entered(body: Node2D) -> void:
	colliding_down = true

func _on_collision_down_body_exited(body: Node2D) -> void:
	colliding_down = false

func _on_collision_left_body_entered(body: Node2D) -> void:
	colliding_left = true

func _on_collision_left_body_exited(body: Node2D) -> void:
	colliding_left = false
