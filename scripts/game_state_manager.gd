extends Node

var gamestate := 0 
# 0 = titlescreen
# 1 = Leaderboard
# 2 = Game

signal gamestateupdated(new_gamestate_id: int)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func new_gamestate(new_gamestate_id: int):
	if (new_gamestate_id == 0):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	elif (new_gamestate_id == 1):
		get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")
	elif (new_gamestate_id == 2):
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		GameManager.score = 0
		gamestateupdated.emit(gamestate)
		


func getGamestate() -> int:
	return gamestate # Alternative zu GameStateManager.gamestate; idk warum ichs geadded habe sieht eif fancy aus


func updategamestate(new_gamestate_id: int):
	print("===========================")
	print("Trigger: Gamestate updated")
	print("===========================")
	print("Old Gamestate: " + str(gamestate))
	print("===========================")
	gamestate = new_gamestate_id
	new_gamestate(gamestate)
	print("New Gamestate: " + str(gamestate))
	print("============================")
