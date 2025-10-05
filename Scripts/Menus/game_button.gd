extends Button
class_name GameButton

func _ready():
	connect("mouse_entered", _on_hovered)
	connect("pressed", _on_pressed)

func _on_hovered():
	SoundManager.play_ui_sound(SoundManager.ui_sounds.HOVER)
	
func _on_pressed():
	SoundManager.play_ui_sound(SoundManager.ui_sounds.CLICK)
