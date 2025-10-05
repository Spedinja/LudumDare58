extends Node

enum menu_types {MAIN_MENU,IN_GAME}
var music_state: menu_types = -1

@export var main_menu_music: MusicTrack
@export var in_game_music: Array[MusicTrack]
var current_sound_tracks: Array[MusicTrack] = []
var current_track_index: int = 0

@export var ui_button_hover_sound: AudioStream
@export var ui_button_click_sound: AudioStream
@export var ui_open_sound: AudioStream
@export var ui_close_sound: AudioStream

@onready var music_player: AudioStreamPlayer = $"Music Player"


#@onready var ui_sfx_player: AudioStreamPlayer = $"UI SFX Pool/UI SFX Player 0"
@export_category("Audio Pools")
@export var ui_sfx_pool: Array[AudioStreamPlayer]
var forced_last_sfx_index: int = 0
@export var attack_sfx_pool: Array[AudioStreamPlayer]
var forced_last_attack_sound_index: int = 0
@export var enemy_sfx_pool: Array[AudioStreamPlayer]
var forced_last_enemy_sound_index: int = 0

signal ui_button_hover
signal ui_button_click
signal ui_open
signal ui_close

enum ui_sounds {HOVER,CLICK,OPEN,CLOSE}

enum player_sound_types {COLLECT,MOVEMENT,COMBAT}
@onready var pickup_sfx_player: AudioStreamPlayer = $"Player Sounds/Pickup SFX Player"
@onready var movement_sfx_player: AudioStreamPlayer = $"Player Sounds/Movement SFX Player"
@onready var combat_sfx_player: AudioStreamPlayer = $"Player Sounds/Combat SFX Player"

var intensity: int = 0

func _ready() -> void:
	var master_idx: int = AudioServer.get_bus_index("Master")
	var new_volume_db = linear_to_db(50 / 100.0) # Set to 50% on start
	AudioServer.set_bus_volume_db(master_idx, new_volume_db)

	load_music(menu_types.MAIN_MENU)
	music_player.finished.connect(_on_music_player_finished)
	ui_button_hover.connect(play_ui_sound.bind(ui_sounds.HOVER))
	ui_button_click.connect(play_ui_sound.bind(ui_sounds.CLICK))
	ui_open.connect(play_ui_sound.bind(ui_sounds.OPEN))
	ui_close.connect(play_ui_sound.bind(ui_sounds.CLOSE))

func load_music(menu_type: menu_types):
	if music_state == menu_type:
		return
	current_sound_tracks.clear()
	current_track_index = 0
	match menu_type:
		menu_types.MAIN_MENU:
			current_sound_tracks.append(main_menu_music)
		menu_types.IN_GAME:
			_build_playlist()
		_:
			print("No such Menu Type: ", menu_type, ".")
	_play_song()
	
func _build_playlist():
	current_sound_tracks = in_game_music.duplicate().filter(func(x): return x.intensity == intensity)
	if current_sound_tracks.size() == 0:
		print_debug("did not find music for intensity")
		current_sound_tracks = in_game_music.duplicate()

func _play_song():
	var next_song = current_sound_tracks[current_track_index]
	if next_song.intensity != intensity:
		_build_playlist()
	current_track_index = (current_track_index + 1) % current_sound_tracks.size()
	if music_player.stream == next_song and music_player.is_playing():
		return
	music_player.stream = current_sound_tracks[0].music
	music_player.play()

func _on_music_player_finished():
	_play_song()

## Plays a Sound depending on the type of action/sound you want it to play
func play_ui_sound(type: ui_sounds):
	match type:
		ui_sounds.HOVER:
			_play_ui_sound_in_pool(ui_button_hover_sound)
		ui_sounds.CLICK:
			_play_ui_sound_in_pool(ui_button_click_sound)
		ui_sounds.OPEN:
			_play_ui_sound_in_pool(ui_open_sound)
		ui_sounds.CLOSE:
			_play_ui_sound_in_pool(ui_close_sound)
		_:
			pass

## Plays an AudioStream in the given "Audio Pool". Returns the last_forced_index.
#func _play_sound_in_pool(sound: AudioStream, audio_player_pool: Array[AudioStreamPlayer], last_forced_index: int) -> int:
	#for audio_player in audio_player_pool:
		#if not audio_player.is_playing():
			#audio_player.stream = sound
			#audio_player.play()
			#return last_forced_index
	#audio_player_pool[last_forced_index].stream = sound
	#audio_player_pool[last_forced_index].play()
	#last_forced_index = (last_forced_index + 1) % audio_player_pool.size()
	#return last_forced_index

## Plays the Sound passed inside the UI SFX "AudioStreamPlayer Pool"
func _play_ui_sound_in_pool(sound: AudioStream):
	for ui_sfx_player in ui_sfx_pool:
		if not ui_sfx_player.is_playing():
			ui_sfx_player.stream = sound
			ui_sfx_player.play()
			return
	ui_sfx_pool[forced_last_sfx_index].stream = sound
	ui_sfx_pool[forced_last_sfx_index].play()
	forced_last_sfx_index = (forced_last_sfx_index + 1) % ui_sfx_pool.size()

func play_attack_sound(sound: AudioStream):
	for attack_sfx_player in attack_sfx_pool:
		if not attack_sfx_player.is_playing():
			attack_sfx_player.stream = sound
			attack_sfx_player.play()
			return
	attack_sfx_pool[forced_last_attack_sound_index].stream = sound
	attack_sfx_pool[forced_last_attack_sound_index].play()
	forced_last_attack_sound_index = (forced_last_attack_sound_index + 1) % attack_sfx_pool.size()

func play_enemy_sound(sound: AudioStream):
	for enemy_sfx_player in enemy_sfx_pool:
		if not enemy_sfx_player.is_playing():
			enemy_sfx_player.stream = sound
			enemy_sfx_player.play()
			return
	enemy_sfx_pool[forced_last_enemy_sound_index].stream = sound
	enemy_sfx_pool[forced_last_enemy_sound_index].play()
	forced_last_enemy_sound_index = (forced_last_enemy_sound_index + 1) % enemy_sfx_pool.size()

func play_player_sound(sound: AudioStream, type: player_sound_types, looping: bool = false):
	match type:
		player_sound_types.COLLECT:
			pickup_sfx_player.stream = sound
			pickup_sfx_player.play()
		player_sound_types.COMBAT:
			combat_sfx_player.stream = sound
			combat_sfx_player.play()
		player_sound_types.MOVEMENT:
			if looping:
				movement_sfx_player.finished.connect(play_player_sound.bind(sound,type,looping))
			else:
				movement_sfx_player.finished.disconnect(play_player_sound)
			movement_sfx_player.stream = sound
			movement_sfx_player.play()
