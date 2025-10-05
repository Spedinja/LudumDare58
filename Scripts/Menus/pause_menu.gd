extends Control
class_name PauseMenu

@export var main_menu_scene: PackedScene = preload("res://Scenes/Menus/main_menu.tscn")


@onready var pause: VBoxContainer = $Pause
@onready var settings: Control = $Settings

@onready var resume_button: Button = $Pause/Resume
@onready var settings_button: Button = $Pause/Settings

func _ready() -> void:
	visibility_changed.connect(_on_toggle_pause_menu)

func _on_toggle_pause_menu():
	if not visible:
		resume_button.release_focus()
		get_tree().paused = false
		return
	resume_button.grab_focus()
	get_tree().paused = true

func _on_resume_pressed() -> void:
	visible = false

func _on_settings_pressed() -> void:
	settings.visible = true
	pause.visible = false

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)
