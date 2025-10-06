extends Node2D

var playerBase: PackedScene = preload("res://Scenes/Player/player.tscn")

func _ready() -> void:
	var currentPlayer = SignalManager.stored_player
	if(currentPlayer):
		currentPlayer.reparent(self)
		currentPlayer.global_position = $Marker2D.global_position
	else:
		var newPlayer = playerBase.instantiate()
		self.add_child(newPlayer)
		newPlayer.global_position = $Marker2D.global_position
	
