extends Node2D
var entered = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !entered:
		call_deferred("_emit_next_layer")

func _emit_next_layer():
	if(!entered):
		var entered = true
		SignalManager.emit_signal("go_to_next_layer")
