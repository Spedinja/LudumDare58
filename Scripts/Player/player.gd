extends CharacterBody2D

@export_category("Movement")
@export var movement_speed: float = 300.0
@export var movement_acceleration = 20.0
@export var dash_duration: float = 0.1
@export var dash_speed: float = 1000.0
@export var dash_cooldown: float = 2.0
var dash_direction: Vector2

@export_category("Combat")
@export var attack_cooldown: float = 0.5
@export var iframes_duration: float = 1.0
var iframes_timer: Timer

var dash_timer: Timer
var dash_cd_timer: Timer
@onready var dash_ghost_scene: PackedScene = preload("res://Scenes/Player/dash_ghost.tscn")

var attack_timer: Timer

var is_dashing: bool = false
var is_attacking: bool = false

var input: PlayerInput

@onready var player_sprite: PlayerAnimatedSprite = $PlayerSprite

@export_category("Sounds")
@export var dash_sfx: AudioStream
@export var walk_sfx: Array[AudioStream]
var walk_sound_index: int = 0
@export var attack_sfx: Array[AudioStream]
@export var hurt_sfx: AudioStream
@export var death_sfx: AudioStream

@export var projectile: PackedScene
@export var upgradeLizards: Array[Lizard]

@onready var hit_flash_animation_player: AnimationPlayer = $HitFlashAnimationPlayer
#var firstProcess = true

func _ready() -> void:
	player_sprite.player_head_sprite.offset = player_sprite.offset
	_get_input()
	_initiate_timers()
	hit_flash_animation_player.play("RESET")
	SignalManager.player_hp_changed.emit(SignalManager.player_current_health)
	player_sprite.frame_changed.connect(on_animation_changed)

func _initiate_timers():
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	add_child(dash_timer)
	dash_timer.timeout.connect(func(): is_dashing = false)
	
	dash_cd_timer = Timer.new()
	dash_cd_timer.one_shot = true
	add_child(dash_cd_timer)
	
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	iframes_timer = Timer.new()
	iframes_timer.one_shot = true
	add_child(iframes_timer)

func _process(_delta: float) -> void:
	#if(firstProcess):
		#if(SignalManager.stored_player != null):
			#SignalManager.on_node_added_once(self)
			#pass
		#firstProcess = false
	_get_input()
	if Input.is_action_just_pressed("DEBUG_Kill_Player"):
		take_damage(999999999)
	if Input.is_action_just_pressed("DEBUG_Damage_Player"):
		take_damage(10)
		#$"CanvasLayer/Pause Menu".visible = not $"CanvasLayer/Pause Menu".visible
	if input.attack_just_pressed:
		is_attacking = true
	if input.attack_just_released:
		is_attacking = false
	if is_attacking:
		_attack()
	if input.dash_just_pressed and input.move_directions != Vector2.ZERO and dash_cd_timer.is_stopped():
		_start_dashing()

func _physics_process(delta: float) -> void:
	_move(delta)

func _move(delta: float):
	if is_dashing:
		velocity = dash_direction.normalized() * dash_speed
		_add_dash_ghost()
	else:
		velocity = lerp(velocity, input.move_directions.normalized() * movement_speed, delta * movement_acceleration)
	_set_animation()
	move_and_slide()

func _set_animation():
	var angle = velocity.angle()
	if velocity.length() < 0.3:
		player_sprite.pause()
	elif angle > -PI/4 and angle <= PI/4:
		player_sprite.play("walk_side")
		player_sprite.flip_h = true
		
		player_sprite.current_default = "default_side"
		if !player_sprite.player_head_sprite.animation.contains("attack"):
			player_sprite.player_head_sprite.play("default_side")
			player_sprite.player_head_sprite.flip_h = true
	elif angle > PI/4 and angle <= 3*PI/4:
		player_sprite.play("walk_down")
		
		player_sprite.current_default = "default_down"
		if !player_sprite.player_head_sprite.animation.contains("attack"):
			player_sprite.player_head_sprite.play("default_down")

	elif angle > -3*PI/4 and angle <= -PI/4:
		player_sprite.play("walk_up")
		
		player_sprite.current_default = "default_up"
		if !player_sprite.player_head_sprite.animation.contains("attack"):
			player_sprite.player_head_sprite.play("default_up")

	elif angle <= -3*PI/4 or angle > 3*PI/4:
		player_sprite.play("walk_side")
		player_sprite.flip_h = false
		
		player_sprite.current_default = "default_side"
		if !player_sprite.player_head_sprite.animation.contains("attack"):
			player_sprite.player_head_sprite.play("default_side")
			player_sprite.player_head_sprite.flip_h = false
	
	
		

func _start_dashing():
	is_dashing = true
	dash_direction = input.move_directions
	dash_timer.start(dash_duration)
	dash_cd_timer.start(dash_cooldown)
	SoundManager.play_player_sound(dash_sfx,SoundManager.player_sound_types.MOVEMENT)

func _add_dash_ghost():
	var ghost: DashGhost = dash_ghost_scene.instantiate()
	ghost.texture = player_sprite.sprite_frames.get_frame_texture(player_sprite.animation, player_sprite.frame)
	ghost.offset = player_sprite.offset
	#ghost.global_position = global_position
	ghost.flip_h = player_sprite.flip_h
	get_parent().add_child(ghost)
	ghost.global_position = global_position

func _attack():
	#print("attack")
	if not attack_timer.is_stopped():
		return
	attack_timer.start(attack_cooldown)
	if upgradeLizards.size() > 5:
		SoundManager.play_player_sound(attack_sfx[1],SoundManager.player_sound_types.COMBAT, false, -0.2, 0.4)
	else:
		SoundManager.play_player_sound(attack_sfx[0],SoundManager.player_sound_types.COMBAT, false, -0.2, 0.4)
	
	
	var newBullet:Bullet = projectile.instantiate()
	for buff in upgradeLizards:
		buff.applyUpgrade(newBullet)
		newBullet.onhits.append(buff)
	#newBullet.global_position = $Marker2D.global_position #+ Vector2(randi_range(0,150),randi_range(0,150))
	var direction = (get_global_mouse_position() - $Marker2D.global_position).normalized()
	newBullet.direction = direction
	#newBullet.printStats()
	self.get_parent().add_child(newBullet)
	newBullet.global_position = $Marker2D.global_position
	
	var angle = direction.angle()

	if angle > -PI/4 and angle <= PI/4:
		player_sprite.player_head_sprite.play("attack_side")
		player_sprite.player_head_sprite.flip_h = true
	elif angle > PI/4 and angle <= 3*PI/4:
		player_sprite.player_head_sprite.play("attack_down")
	elif angle > -3*PI/4 and angle <= -PI/4:
		player_sprite.player_head_sprite.play("attack_up")
		pass
	elif angle <= -3*PI/4 or angle > 3*PI/4:
		player_sprite.player_head_sprite.play("attack_side")
		player_sprite.player_head_sprite.flip_h = false

func take_damage(amount: float):
	if is_dashing or not iframes_timer.is_stopped():
		return
	SoundManager.play_player_sound(hurt_sfx,SoundManager.player_sound_types.COMBAT)
	SignalManager.player_current_health -= amount
	SignalManager.player_hp_changed.emit(SignalManager.player_current_health)
	hit_flash_animation_player.play("hitflash")
	iframes_timer.start(iframes_duration)
	if SignalManager.player_current_health <= 0:
		die()

func die():
	SignalManager.lizard_killed()
	
	# Pause Game if not switching to Main Menu
	# Change Player Sprite to Dead??
	# Switch Scene or bring up Game Over Screen

	
func on_animation_changed():
	if player_sprite.frame == 1:
		SoundManager.play_player_sound(walk_sfx[0], SoundManager.player_sound_types.MOVEMENT)
	elif player_sprite.frame == 3:
		SoundManager.play_player_sound(walk_sfx[1], SoundManager.player_sound_types.MOVEMENT)
	
	
func _get_input():
	var move_direction: Vector2 = Vector2(Input.get_axis("Move Left", "Move Right"), Input.get_axis("Move Up", "Move Down"))
	var attack_just_pressed: bool = Input.is_action_just_pressed("Attack")
	var attack_just_released: bool = Input.is_action_just_released("Attack")
	var dash_just_pressed: bool = Input.is_action_just_pressed("Dash")
	input = PlayerInput.new(move_direction, attack_just_pressed, attack_just_released, dash_just_pressed)

class PlayerInput:
	var move_directions: Vector2 = Vector2.ZERO
	var attack_just_pressed: bool = false
	var attack_just_released: bool = false
	var dash_just_pressed: bool = false

	func _init(_move_directions, _attack_just_pressed, _attack_just_released, _dash_just_pressed) -> void:
		move_directions = _move_directions
		attack_just_pressed = _attack_just_pressed
		attack_just_released = _attack_just_released
		dash_just_pressed = _dash_just_pressed

	func _to_string() -> String:
		var tmp_str = "Movement Directions: " + str(move_directions) + ",\n"
		tmp_str += "Attack just pressed: " + str(attack_just_pressed) + ",\n"
		tmp_str += "Attack just released: " + str(attack_just_released) + ",\n"
		tmp_str += "Dash just pressed: " + str(dash_just_pressed) + ",\n"
		return tmp_str
