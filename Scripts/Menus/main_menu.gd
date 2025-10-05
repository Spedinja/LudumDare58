extends Control

@onready var game_scene: PackedScene # = preload()
@onready var credits: ColorRect = $Credits
@onready var settings: Control = $Settings

@onready var main_menu_buttons: VBoxContainer = $MainMenuButtons

@onready var play_button: Button = $MainMenuButtons/Play
@onready var credits_button: Button = $MainMenuButtons/Credits
@onready var back_button: Button = $Credits/Back
@onready var settings: Button = $VBoxContainer/Settings

@onready var sfx_button_click: AudioStreamPlayer2D = $sfx_button_click

func _ready() -> void:
	SoundManager.load_music(SoundManager.menu_types.MAIN_MENU)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	sfx_button_click.play()

func _on_settings_pressed() -> void:
	settings.visible = true
	main_menu_buttons.visible = false

func _on_credits_pressed() -> void:
	credits.visible = true
	main_menu_buttons.visible = false
	back_button.grab_focus()
	sfx_button_click.play()

func _on_back_pressed() -> void:
	credits.visible = false
	main_menu_buttons.visible = true
	credits_button.grab_focus()
	sfx_button_click.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
