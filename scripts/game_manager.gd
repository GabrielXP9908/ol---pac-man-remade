extends Node

var score := 0
var highscore := 0
var recived_extra_live := false
var lives := 4
var levels := 0
var levels_capped := 0

var coins := 0

var pacman_x: float
var pacman_y: float
var pacman_direction: int
var Blinky_pos: Vector2

var released_ghost: int = 0
# 1 = Blinky
# 2 = Pinky
# 3 = Inky
# 4 = Clyde
var frigthend: bool = false
var combo: int = 0
var last_combo: int = 0
var last_time: float = 0.0

signal newcombo()

#signal scoreUpdated(new_score: int)
#signal highScoreUpdated(new_highscore: int)
signal killPacMan()
signal gameOver(score: int, level: int)
signal releaseNewGhostAsAntiCamp()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if combo > last_combo:
		if combo == 1:
			score += 200
		elif combo == 2:
			score += 400
		elif combo == 3:
			score += 800
		elif combo == 4:
			score += 1200
		last_combo = combo
	
	
	#print(combo)
	
	if (levels > 0 and levels < 20):
		levels_capped = levels
	updateHighScore()
	levelcompletecheck()
	
	if last_time < FT.time_left:
		newcombo.emit()
		combo = 0
		last_combo = 0
	
	last_time = FT.time_left
	
	if FT.time_left == 0:
		frigthend = false
		combo = 0
		last_combo = 0
	else:
		frigthend = true


func updateScore(operation: String, count: int):
	if (operation=="add"):
		score += count
		updateHighScore()
		updateExtraLive()
	elif (operation=="remove"):
		score -= count
		updateHighScore()
		updateExtraLive()
	elif (operation=="reset"):
		score = 0
		updateHighScore()
		updateExtraLive()
	elif (operation=="set"):
		score = count
		updateHighScore()
		updateExtraLive()
	else:
		print("Error: not a valid operation! Please use one of the following: add, remove, reset, set")

func updateHighScore():
	if (score>=highscore):
		highscore = score

func resetHighScore():
	highscore = 0

func updateExtraLive():
	if (score>=10000 and !recived_extra_live):
		recived_extra_live = true
		lives += 1

func PacManDieNow():
	killPacMan.emit()

func GameOver():
	gameOver.emit(score, levels)
	GameStateManager.updategamestate(0)
	lives = 4
	recived_extra_live = false
	levels = 0
	score = 0
	coins = 0

func levelcompletecheck():
	if (coins == 244):
		nextLevel()

func nextLevel():
	GameStateManager.new_gamestate(2)

func positionupdate(func_x: float, func_y: float):
	pacman_x = func_x
	pacman_y = func_y

func getpacmanposition() -> Vector2:
	return Vector2(pacman_x, pacman_y)

func directionupdate(direction: int):
	pacman_direction = direction #+ 1

func getpacmandirection() -> int:
	return pacman_direction

func updateBlinkypos(blinky_position: Vector2):
	Blinky_pos = blinky_position

func getblinkyposition() -> Vector2:
	return Blinky_pos
