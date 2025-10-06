extends Node2D

@export var geckoFrames: Array[SpriteFrames]
@onready var gecko_sprite: AnimatedSprite2D = $geckoSprite
var dataLizard: Lizard
var caged = true
var collected = false
var speed = 50
var direction = Vector2(0,0)
@export var cage: Enemy
var counter = 0
var random = Vector2(0,0)
@onready var rarity_glitter_particles: GPUParticles2D = $RarityGlitterParticles

@export var collect_sfx: AudioStream

func _ready() -> void:
	dataLizard = LootPoolSelector.select_items(1,Lizard,SignalManager.game_progression)[0]
	gecko_sprite.sprite_frames = geckoFrames[dataLizard.id]
	matchRarity()
	
func matchRarity():
	match[dataLizard.rarity]:
		["Common"]:
			pass
		["Rare"]:
			rarity_glitter_particles.emitting = true
			rarity_glitter_particles.modulate = (Color(0.897, 0.001, 0.9))
		["Legendary"]:
			rarity_glitter_particles.emitting = true
			rarity_glitter_particles.modulate = (Color(0.957, 0.471, 0.027, 1.0))
		[_]:
			print("rarityNotFound")
			print("DATALIZARD RARITY   " + dataLizard.rarity)
			
func _process(delta: float) -> void:
	if(collected):
		if(counter == 60):
			random = Vector2(randi_range(-20,20), randi_range(-20,20))
			counter = 0
		var parent = get_parent()
		var velocity = parent.velocity
		var trail_distance = clamp(velocity.length() / 300.0, 0.0, 1.0) * 50.0  # 0–50px behind
		var offset = -velocity.normalized() * trail_distance
		offset = offset + random
		direction = (parent.global_position + offset - self.global_position).normalized()
		self.position = self.position + delta * speed * direction
		counter +=1
	_set_animation()

func _set_animation():
	var angle = direction.angle()
	var velocity = get_parent().velocity
	if(velocity.length() > 0.3):
		angle = velocity.angle()
	if direction.length() < 0.3:
		gecko_sprite.pause()
	elif angle > -PI/4 and angle <= PI/4:
		gecko_sprite.play("walk_side")
		gecko_sprite.flip_h = true
	elif angle > PI/4 and angle <= 3*PI/4:
		gecko_sprite.play("walk_down")
	elif angle > -3*PI/4 and angle <= -PI/4:
		gecko_sprite.play("walk_up")
	elif angle <= -3*PI/4 or angle > 3*PI/4:
		gecko_sprite.play("walk_side")
		gecko_sprite.flip_h = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !collected and !caged:
		collected = true
		#var newLiz = dataLizard.duplicate(true)
		#newLiz.basestats = dataLizard.basestats
		#newLiz.budgetStats = dataLizard.budgetStats
		body.upgradeLizards.append(dataLizard)
		call_deferred("deferredActions", body)
		#call_deferred("reparent", body, true)
		#$Area2D/CollisionShape2D.disabled = true
		#cage.call_deferred("die")
		SoundManager.play_player_sound(collect_sfx,SoundManager.player_sound_types.COLLECT)

func deferredActions(body: Node2D):
	self.reparent(body, true)
	$Area2D/CollisionShape2D.disabled = true
	cage.die()
