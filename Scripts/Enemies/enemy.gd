extends CharacterBody2D

@export var speed: float = 150
@export var damage: float = 10

var player_in_range: bool = false
var follow_object

func _physics_process(_delta: float) -> void:
	_move()
	_attack()

func _move():
	if not player_in_range:
		return
	var direction = (follow_object.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

func _attack():
	if not player_in_range:
		return

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	player_in_range = true
	follow_object = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	player_in_range = false
