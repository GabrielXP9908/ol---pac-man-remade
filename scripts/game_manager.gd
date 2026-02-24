extends Node

var score := 0
var highscore := 0

var gamestate = 0 # 0 = TitleScreen, 1 = Game, 2 = Ingame, 3 = End Screen

signal scoreUpdated(new_score: int)
signal highScoreUpdated(new_highscore: int)
signal gamestateUpdated(new_gamestate_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updateScore(operation: String, count: int):
	if (operation=="add"):
		score += count
		scoreUpdated.emit(score)
	elif (operation=="remove"):
		score -= count
		scoreUpdated.emit(score)
	elif (operation=="reset"):
		score = 0
		scoreUpdated.emit(score)
	elif (operation=="set"):
		score = count
		scoreUpdated.emit(score)
	else:
		print("Error: not a valid operation! Please use one of the following: add, remove, reset, set")

func updateHighScore():
	if (score>=highscore):
		highscore = score
		highScoreUpdated.emit(highscore)

func resetHighScore():
	highscore = 0
	highScoreUpdated.emit(highscore)

func updateGameState(new_gamestate_id: int):
	gamestateUpdated.emit(new_gamestate_id)
	gamestate = new_gamestate_id
