extends Enemy
@onready var baby_lizard: Node2D = $BabyLizard
@onready var cage_back: AnimatedSprite2D = $cageBack
@onready var cage_fore: AnimatedSprite2D = $EnemySprite




func _ready() -> void:
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
