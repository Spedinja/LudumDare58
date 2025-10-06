extends TextureProgressBar
class_name HealthBar

var catch_up_timer: Timer
@export var catch_up_delay: float = 0.4

@onready var damage_bar: TextureProgressBar = $DamageBar

var health = 0

func _ready() -> void:
	catch_up_timer = Timer.new()
	catch_up_timer.one_shot = true
	catch_up_timer.wait_time = catch_up_delay
	add_child(catch_up_timer)
	catch_up_timer.timeout.connect(_catch_up_on_health_bar)
	SignalManager.player_hp_changed.connect(_on_player_hp_changed)

func init_health(_health,_max_health):
	health = _health
	max_value = _max_health
	value = _health
	damage_bar.max_value = _max_health
	damage_bar.value = _health

func _on_player_hp_changed(new_value: float):
	var prev_health = health
	health = min(max_value, new_value)
	value = health
	
	if health < prev_health:
		catch_up_timer.start()
	else:
		damage_bar.value = health

func _catch_up_on_health_bar():
	damage_bar.value = health
