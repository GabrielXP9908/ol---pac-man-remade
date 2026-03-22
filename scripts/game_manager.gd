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

#signal scoreUpdated(new_score: int)
#signal highScoreUpdated(new_highscore: int)
signal killPacMan()
signal gameOver(score: int, level: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (levels > 0 and levels < 20):
		levels_capped = levels
	updateHighScore()
	levelcompletecheck()

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
