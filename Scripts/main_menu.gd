extends Control

@onready var game_scene: PackedScene # = preload()
@onready var credits: ColorRect = $Credits

@onready var play_button: Button = $VBoxContainer/Play
@onready var credits_button: Button = $VBoxContainer/Credits
@onready var back_button: Button = $Credits/Back
@onready var settings: Button = $VBoxContainer/Settings

@onready var sfx_button_click: AudioStreamPlayer2D = $sfx_button_click

func _ready() -> void:
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	sfx_button_click.play()

func _on_credits_pressed() -> void:
	credits.visible = true
	back_button.grab_focus()
	sfx_button_click.play()

func _on_back_pressed() -> void:
	credits.visible = false
	credits_button.grab_focus()
	sfx_button_click.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
