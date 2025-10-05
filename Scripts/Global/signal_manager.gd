extends Node

signal player_hp_changed(new_value: float)

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
	
]

func lizard_killed():
	lizards_killed += 1

func get_current_lizard() -> String:
	var current_lizard: String
	current_lizard = lizard_names[lizards_killed % lizard_names.size()]
# +1 because the number of the current lizard is always the number of killed lizards +1
	match lizards_killed+1:
		20:
			current_lizard = "Please don't kill me too-ary"
		42:
			current_lizard = "Mary Jane"
		69:
			current_lizard = "Nice"
		100:
			current_lizard = "Why are you killing all dem cute Lizards :("
	return current_lizard
