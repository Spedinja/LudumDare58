extends Button
class_name GameButton

func _ready():
	connect("mouse_entered", _on_hovered)

func _on_hovered():
	SoundManager.play_ui_sound(SoundManager.ui_sounds.HOVER)
