extends Node

var levels: Array[LevelData]

var main_scene : Node2D = null
var loaded_level: Levels = null 
var levelId : int = -1
func unload_level()->void:
	if is_instance_valid(loaded_level):
		loaded_level.queue_free()

	loaded_level = null

func  load_level(level_id : int) -> void:
	print("Loading level : %s" % level_id)
	print(get_parent().get_name())
	print("Points are :%s" %GameManager.return_points())
	unload_level()
	GameManager.remove_points()
	
	
	var level_data = get_level_data_by_id(level_id)

	if not level_data:
		return 

	var level_path = "res://scenes/%s.tscn" % level_data.level_path 
	var level_res := load(level_path)
	if level_res:
		loaded_level = level_res.instantiate()
		main_scene.add_child(loaded_level)
	else:
		print("Level does not exist")
func get_level_data_by_id(id : int) -> LevelData:
	var level_to_return : LevelData = null
	for lvl: LevelData in levels:
		if lvl.level_id == id :
			level_to_return = lvl
	levelId = id
	return level_to_return
	
func load_main():
	load("res://scenes/Scenes/mainscene.tscn")
	
