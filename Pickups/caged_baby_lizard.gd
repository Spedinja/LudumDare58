extends Enemy
@onready var baby_lizard: Node2D = $BabyLizard
@onready var cage_back: AnimatedSprite2D = $cageBack
@onready var cage_fore: AnimatedSprite2D = $EnemySprite

@export var break_sfx: AudioStream


func _ready() -> void:
	health = 10
	
	vfx_fire = vfx_fireScene.instantiate()
	vfx_fire.emitting = false
	add_child(vfx_fire)
	vfx_cold = vfx_coldScene.instantiate()
	vfx_cold.emitting = false
	add_child(vfx_cold)
	
	coldTimer = Timer.new()
	coldTimer.one_shot = true
	add_child(coldTimer)
	coldTimer.wait_time = 2
	coldTimer.timeout.connect(coldTimeout)
	
	fireTimer = Timer.new()
	fireTimer.one_shot = true
	add_child(fireTimer)
	fireTimer.wait_time = 0.5
	fireTimer.timeout.connect(fireTicks)
	
	cooldownTimer = Timer.new()
	cooldownTimer.one_shot = true
	add_child(cooldownTimer)
	cooldownTimer.wait_time = attackCD
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
