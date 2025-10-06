extends ProgressBar
class_name EnemyHealthBar

var catch_up_timer: Timer
@export var catch_up_delay: float = 0.4

@onready var damage_bar: TextureProgressBar = $DamageBar

var health = 0: set = _set_health

func _ready() -> void:
	catch_up_timer = Timer.new()
	catch_up_timer.one_shot = true
	catch_up_timer.wait_time = catch_up_delay
	add_child(catch_up_timer)
	catch_up_timer.timeout.connect(_catch_up_on_health_bar)
	init_health(SignalManager.player_current_health,SignalManager.player_max_health)

func init_health(_health,_max_health):
	health = _health
	max_value = _max_health
	value = _health
	damage_bar.max_value = _max_health
	damage_bar.value = _health

func _set_health(new_value: float):
	var prev_health = health
	health = min(max_value, new_value)
	value = health
	
	if health <= 0:
		queue_free()
	
	if health < prev_health:
		catch_up_timer.start()
	else:
		_catch_up_on_health_bar()

func _catch_up_on_health_bar():
	damage_bar.value = health
