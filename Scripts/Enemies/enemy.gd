extends CharacterBody2D
class_name Enemy

@export var speed: float = 150
@export var damage: float = 10
@export var health: float = 50
@export var attackRange: float = 0
var is_attacking: bool = false
var attackCD: float = 2
var cooldownTimer: Timer

var player_in_range: bool = false
var follow_object

var dedge: bool = false

@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite

@onready var detection_area: Area2D = $DetectionArea

@onready var sfx_damage: AudioStreamPlayer2D = get_node_or_null("sfx_damage")
@onready var sfx_step: AudioStreamPlayer2D = get_node_or_null("sfx_step")
@onready var sfx_dying: AudioStreamPlayer2D = get_node_or_null("sfx_dying")

@onready var enemy_health_bar: EnemyHealthBar = $EnemyHealthBar

var vfx_fireScene:PackedScene  = preload("res://Scenes/OtherGameObjects/fire_particles.tscn")
var vfx_coldScene:PackedScene  = preload("res://Scenes/OtherGameObjects/iceparticle.tscn")
var vfx_fire: GPUParticles2D
var vfx_cold: GPUParticles2D
var fireTimer:Timer
var coldTimer:Timer
var burnStacks = 0
var maxHp = health

func _ready() -> void:
	enemy_health_bar.init_health(health, maxHp)
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	enemy_sprite.frame_changed.connect(on_animation_changed)
	sfx_dying.finished.connect(die)
	
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



func _physics_process(_delta: float) -> void:
	if health <= 0:
		enemy_sprite.visible = false;
		return
	_move()
	_attack()

func coldTimeout():
	speed = speed*2.0
	vfx_cold.emitting = false

func fireTicks():
	burnStacks = max(burnStacks - 1, 0)
	take_damage(maxHp * 0.03) 
	if(burnStacks > 0):
		fireTimer.start()
	else:
		vfx_fire.emitting = false
		
func burn(stacks):
	burnStacks += stacks
	if(fireTimer.is_stopped()):
		vfx_fire.emitting = true
		fireTimer.start()
	
func slow():
	if(coldTimer.is_stopped()):
		vfx_cold.emitting = true
		speed = speed/2.0
		coldTimer.start()
	else:
		coldTimer.start()

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

func _attack() -> bool:
	if not player_in_range or not cooldownTimer.is_stopped():
		return false
	if(self.global_position.distance_to(follow_object.global_position) > attackRange):
		return false
	cooldownTimer.start()
	return true


	
func take_damage(amount: float):
	if dedge:
		return
	health -= amount
	enemy_health_bar._set_health(health)
	sfx_damage.play()
	if health <= 0:
		dedge = true
		sfx_dying.play()
	

func die():
	vfx_cold.call_deferred("queue_free")
	vfx_fire.call_deferred("queue_free")
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
