extends Enemy
class_name ShotgunRat

@onready var sfx_shoot: AudioStreamPlayer2D = $sfx_shoot

func _attack():
	pass
	#sfx_shoot.play()
