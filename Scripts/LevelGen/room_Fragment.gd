extends Node2D

class_name Room_Fragment

@export var has_cagedGecko: bool = false
@onready var cagedgecko_scene = preload("res://Scenes/Enemies/enemy.tscn")

func _ready():
	if has_cagedGecko:
		spawn_cagedgecko()

func spawn_cagedgecko():
	var spawn_point = find_child("CagedGecko_Spawner", true, false)
	if not spawn_point:
		push_warning("No 'CagedGecko_Spawner' found in room!")
		return
		
	var gecko = cagedgecko_scene.instantiate()
	spawn_point.add_child(gecko)
	gecko.position = Vector2.ZERO
