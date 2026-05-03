extends Node

var gamestate := 0 
# 0 = titlescreen
# 1 = Account
# 2 = Game
# 3 = Start-Intro

signal gamestateupdated(new_gamestate_id: int)

#region INTERN
# INTERN!!!!!!!!!!!!!!
# FÜR GAMESTATE ÄNDERN updategamestate() NUTZEN!!!!!!!!!
func new_gamestate(new_gamestate_id: int):
	if (new_gamestate_id == 0):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	elif (new_gamestate_id == 1):
		get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")
	elif (new_gamestate_id == 2):
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		gamestateupdated.emit(gamestate)
	elif (new_gamestate_id == 3):
		get_tree().change_scene_to_file("res://scenes/IntroScene.tscn")
#endregion

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
