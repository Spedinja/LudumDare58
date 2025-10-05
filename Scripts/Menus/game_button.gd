extends Button
class_name GameButton

func _ready():
	mouse_entered.connect(_on_hovered)
	pressed.connect(_on_pressed)

func _on_hovered():
	SoundManager.play_ui_sound(SoundManager.ui_sounds.HOVER)

func _on_pressed():
	SoundManager.play_ui_sound(SoundManager.ui_sounds.CLICK)
