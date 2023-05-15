extends Node

var current_scene = null

var playerFaction: int
var combatPace: float
var rangeFactor: float
var crewAccuracyFactor: float

var building = false
var num_islands = 0

var unit_list = []
var default_budgets = {"0": 200, "1": 200, "2": 200}
var faction_budgets = {"0": 200, "1": 200, "2": 200}
var strike_multiplier = 8

func _ready():
	# Global variables
	combatPace = 2
	rangeFactor = 0.05
	crewAccuracyFactor = 0.05
	
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func change_to_main_map(path, squadron, num_islands):
	call_deferred("goto_main_map", path, squadron, num_islands)

func change_to_main_map2(path):
	call_deferred("goto_main_map2", path)

func goto_main_map(path, squadron_data, num_islands):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
	current_scene.init(squadron_data, num_islands)

func goto_main_map2(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
	current_scene.init(unit_list, num_islands)

func change_playerFaction(new_faction):
	playerFaction = new_faction

func set_game_settings(settings):
	# dict of budgets, combat_pace, range_factor, crew_factor
	faction_budgets = settings["budgets"]
	combatPace = settings["combat_pace"]
	rangeFactor = settings["range_factor"]
	crewAccuracyFactor = settings["crew_factor"]

func get_playerFaction():
	return playerFaction

func get_combatPace():
	return combatPace
	
func get_rangeFactor():
	return rangeFactor

func get_crewAccuracyFactor():
	return crewAccuracyFactor

func add_unit(unit):
	unit_list.append(unit)

func get_faction_budget(faction):
	return faction_budgets[faction]

func use_budget(budget, faction):
	faction_budgets[faction] = budget

func restore_budgets():
	faction_budgets = default_budgets

func set_num_islands(islands):
	num_islands = islands

func get_strike_multiplier():
	return strike_multiplier
