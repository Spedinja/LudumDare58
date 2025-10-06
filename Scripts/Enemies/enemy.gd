extends CharacterBody2D
class_name Enemy

@export var speed: float = 150
@export var damage: float = 10
@export var health: float = 50

var is_attacking: bool = false

var player_in_range: bool = false
var follow_object

@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite

@onready var detection_area: Area2D = $DetectionArea

@onready var sfx_damage: AudioStreamPlayer2D = $sfx_damage
@onready var sfx_step: AudioStreamPlayer2D = $sfx_step


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	enemy_sprite.frame_changed.connect(on_animation_changed)


func _physics_process(_delta: float) -> void:
	_move()
	_attack()

func _move():
	if not player_in_range:
		enemy_sprite.pause()
		return
	var direction = (follow_object.global_position - global_position).normalized()
	
	var angle = direction.angle()
	if angle > -PI/4 and angle <= PI/4:
		enemy_sprite.play("walk_side")
		enemy_sprite.flip_h = false
	elif angle > PI/4 and angle <= 3*PI/4:
		enemy_sprite.play("walk_down")
	elif angle > -3*PI/4 and angle <= -PI/4:
		enemy_sprite.play("walk_up")
	elif angle <= -3*PI/4 or angle > 3*PI/4:
		enemy_sprite.play("walk_side")
		enemy_sprite.flip_h = true
	else:
		enemy_sprite.pause()
	
	velocity = direction * speed
	if global_position.distance_to(follow_object.position) > 3:
		move_and_slide()

func _attack():
	if not player_in_range:
		return

func take_damage(amount: float):
	health -= amount
	sfx_damage.play()
	if health <= 0:
		die()

func die():
	call_deferred("queue_free")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	player_in_range = true
	follow_object = body
	SoundManager.add_enemy()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	player_in_range = false
	SoundManager.remove_enemy()
	
func on_animation_changed():
	if enemy_sprite.animation.contains("walk"):
		if enemy_sprite.frame == 0 || enemy_sprite.frame == 2:
			sfx_step.play()
