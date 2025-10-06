extends Enemy
@onready var baby_lizard: Node2D = $BabyLizard
@onready var cage_back: AnimatedSprite2D = $cageBack
@onready var cage_fore: AnimatedSprite2D = $EnemySprite

@export var break_sfx: AudioStream


func _ready() -> void:
	health = 10
	pass
func _move():
	pass
	
func take_damage(amount: float):
	health -= amount
	if health <= 0:
		baby_lizard.caged = false
		cage_back.play("broken")
		cage_fore.play("broken")
		$Hitbox.disabled = true
		SoundManager.play_player_sound(break_sfx,SoundManager.player_sound_types.COLLECT)
