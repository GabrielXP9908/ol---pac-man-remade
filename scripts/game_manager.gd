extends Node

var score := 0
var highscore := 0
var recived_extra_live := false
var lives := 4
var levels := 0
var levels_capped := 0

var gamestate = 0 # 0 = TitleScreen, 1 = Game, 2 = Ingame, 3 = End Screen

var coins := 0

#signal scoreUpdated(new_score: int)
#signal highScoreUpdated(new_highscore: int)
signal gamestateUpdated(new_gamestate_id: int)
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

func updateGameState(new_gamestate_id: int):
	gamestateUpdated.emit(new_gamestate_id)
	gamestate = new_gamestate_id

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
