extends Node
class_name Bullet

@export var dmg: float = 1
@export var speed: float = 1
@export var area: float = 1
@export var pierce: float = 0
@export var bounce: float = 0
@export var fire: float = 0
@export var ice: float = 0
@export var electric: float = 0
@export var exploding: float = 0
@export var lifetime: float = 5

var direction: Vector2 = Vector2(0,0)
var velocity: Vector2 = direction * speed

func _ready() -> void:
	$lifetime.wait_time = lifetime
	$lifetime.start()
	velocity = direction * speed
	
	
func _process(delta: float) -> void:
	#self.position += direction * speed * delta
	pass

func _physics_process(delta):
	var next_position = self.global_position + velocity * delta

	# 1. Do a raycast
	var space_state = $Area2D.get_world_2d().direct_space_state
	var result = space_state.intersect_ray(self.global_position, next_position, [self])

	if result:
		 # 2. Reflect velocity around collision normal
		var normal = result.normal
		velocity = velocity.bounce(normal)

		# 3. Adjust position slightly to avoid clipping
		self.global_position = result.position + velocity.normalized() * 1.0
	else:
		self.global_position = next_position


func _on_lifetime_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is TileMap):
		if(bounce == 0):
			call_deferred("queue_free")
	else:
		if(pierce == 0 && bounce == 0):
			call_deferred("queue_free")
			
		
