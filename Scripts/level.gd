extends Node2D

@onready var pause_menu: PauseMenu = $"CanvasLayer/Pause Menu"
@onready var game_over_screen: Control = $"CanvasLayer/Game Over Screen"
@onready var lizard_name_died: Label = $"CanvasLayer/Game Over Screen/Panel/VBoxContainer/LizardNameDied"
@onready var depth_label: Label = $"CanvasLayer/Game Over Screen/Panel/VBoxContainer/Depth"
@onready var lizard_count_label: Label = $"CanvasLayer/Game Over Screen/Panel/VBoxContainer/LizardCount"
@onready var back_to_menu_button: GameButton = $"CanvasLayer/Game Over Screen/Panel/VBoxContainer/BackToMenu"


var _player_died: bool = false

func _ready() -> void:
	SignalManager.player_died.connect(_on_death)
	lizard_name_died.text = SignalManager.get_current_lizard() + "\ndied. :c"
	game_over_screen.visibility_changed.connect(_on_game_over_toggle)

func _process(_delta: float) -> void:
	if _player_died:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.visible = true

func _on_death():
	_player_died = true
	get_tree().paused = true
	var player: Player = get_tree().get_first_node_in_group("Player")
	var lizard_count: int = -1
	if player:
		lizard_count = player.upgradeLizards.size()
	lizard_count_label.text = "Lizards Collected: " + str(lizard_count)
	depth_label.text = "Depth: " + str(SignalManager.cleared_layers)
	game_over_screen.visible = true

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	back_to_menu_button.release_focus()
	get_tree().change_scene_to_packed(SignalManager.main_menu_scene)

func _on_game_over_toggle():
	if game_over_screen.visible:
		back_to_menu_button.grab_focus()
	else:
		back_to_menu_button.release_focus()
