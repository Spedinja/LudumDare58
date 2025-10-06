extends Node

signal player_hp_changed(new_value: float)
signal go_to_next_layer

var main_menu_scene: PackedScene = preload("res://Scenes/Menus/main_menu.tscn")
var game_scene: PackedScene = preload("res://Scenes/LevelGen/test_levelGen.tscn")

var game_progression: float = 0.0
var cleared_layers: int = 0
var stored_player: Node = null
var roomGenCd = false

var lizards_killed: int = 0
var lizard_names: Array[String] = [
	"Larry",
	"Harry",
	"Gary",
	"Mary",
	"Sir Fortenberry",
	"Barry",
	"Carrie",
	"Perry",
	"Quarry",
	"Hillary",
	"Rosary",
	"Annieversary",
	"Zaccary",
	"Terry",
	"Cherry",
	"Jerry",
	"B. Lizard",
	"Lizzy Lizbourne",
	"Von Wegen Lizbeth",
	"Liz Pine",
	"Liztopher Waltz",
	"Liztian Bale",
	"Lizen to your Heart",
	"Liz Khalifa",
	"Lizzl Wayne",
	"Franz Lizzt",
	"I'm a Lizbian",
	"Liza Kudrow",
	"Liztina Anguilera",
]

func _ready():
	connect("go_to_next_layer", Callable(self, "generate_new_dungeon"))
	return
	

func generate_new_dungeon():
	if(roomGenCd):
		return
	roomGenCd = true
	var genTimer = Timer.new()
	genTimer.one_shot = true
	genTimer.timeout.connect(func(): roomGenCd = false)
	get_tree().root.add_child(genTimer)
	genTimer.start(2)
	print("WARRRRRRRRRRRRRRRRRRRRRRRRNING NEW DUNGEON")
	game_progression += 5.0
	game_progression = clamp(game_progression, 0.0, 100.0)
	cleared_layers += 1

	#find & store the player before reloading
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		#player.reparent(self)
		stored_player = player
		stored_player.reparent(get_tree().root) # keep it alive through scene change
		stored_player.global_position = Vector2(0,0)
		#player.get_parent().remove_child(player)

	#reload level
	var level_gen = get_tree().root.find_child("Level", true, false)
	if level_gen:
		var level_scene = level_gen.scene_file_path
		get_tree().change_scene_to_file(level_scene)
	else:
		push_error("LevelGenerator not found in scene tree!")
		return

	# Wait to finish loading before replacing player
	#get_tree().connect("node_added", Callable(self, "_on_node_added_once"), CONNECT_ONE_SHOT)

func on_node_added_once(node: Node) -> void:
	print("shouldReplace")
	if node.name == "Player" and stored_player:
		print("player Replace")
		var parent:Node = node.get_parent() as Node
		#var index = parent.get_child_index(node)
		var spawn_pos = node.global_position

		node.queue_free()  #remove new placeholder
		stored_player.global_position = spawn_pos
		parent.add_child(stored_player)
		#parent.move_child(stored_player, index)
		stored_player.global_position = spawn_pos
		stored_player = null


func lizard_killed():
	lizards_killed += 1

func get_current_lizard() -> String:
	var current_lizard: String
	# lizards_killed % lizard_names.size()
	var lizard_index = randi_range(0, lizard_names.size() - 1)
	current_lizard = lizard_names[lizard_index]
	var special: bool = false
# +1 because the number of the current lizard is always the number of killed lizards +1
	match lizards_killed+1:
		1:
			current_lizard = "Larry"
		20:
			current_lizard = "Please don't kill me too-ary"
		42:
			current_lizard = "Mary Jane"
		69:
			current_lizard = "Nice"
			special = true
		100:
			current_lizard = "Why are you killing all dem cute Lizards :("
			special = true
	if not special:
		current_lizard += "\nthe Lizard Wizard"
	
	return current_lizard
