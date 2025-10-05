extends Control

@export var connection_button: Button
@export var connection_menu: Control

@onready var volume_per_cent: Label = $VBoxContainer/Sound/VolumePerCent
@onready var volume_slider: HSlider = $VBoxContainer/Sound/VolumeSlider
var master_idx: int

@onready var back_button: Button = $VBoxContainer/Back

func _ready():
	master_idx = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_idx)) * 100
	visibility_changed.connect(_on_toggle_settings)

func _on_toggle_settings():
	if not visible:
		connection_menu.visible = true
		connection_button.grab_focus()
		return
	back_button.grab_focus()

func _on_volume_slider_value_changed(value: float) -> void:
	# Update volume label
	volume_per_cent.text = str(int(value)) + "%"
	# Change master volume
	var new_volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(master_idx, new_volume_db)

func _on_back_pressed() -> void:
	visible = false
