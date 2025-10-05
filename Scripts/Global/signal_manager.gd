extends Node

signal player_hp_changed(new_value: float)
signal go_to_next_layer

var game_progression: float = 0.0
var cleared_layers: int = 0

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
	game_progression += 5.0
	game_progression= clamp(game_progression, 0.0, 100.0)
	cleared_layers += 1
	var level_gen = get_tree().root.find_child("Level", true, false)
	if level_gen:
		var level_scene = level_gen.scene_file_path  # get the original scene file path
		get_tree().change_scene_to_file(level_scene)
	else:
		push_error("LevelGenerator not found in scene tree!")
	return

func lizard_killed():
	lizards_killed += 1

func get_current_lizard() -> String:
	var current_lizard: String
	current_lizard = lizard_names[lizards_killed % lizard_names.size()]
	var special: bool = false
# +1 because the number of the current lizard is always the number of killed lizards +1
	match lizards_killed+1:
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
