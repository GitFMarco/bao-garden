extends Node


const SETTINGS_PATH := "user://settings.cfg"

const MUSIC := preload("res://audio/game-music.ogg")
const SFX_CLICK := preload("res://audio/button-touch.wav")
const SFX_SEED := preload("res://audio/seed.wav")
const SFX_WATER := preload("res://audio/water.wav")
const SFX_HARVEST := preload("res://audio/harvest.wav")

var music_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var seed_player: AudioStreamPlayer
var water_player: AudioStreamPlayer
var harvest_player: AudioStreamPlayer

var _config := ConfigFile.new()


func _ready() -> void:
	music_player = _make_player(MUSIC, "Music")
	music_player.play()
	click_player = _make_player(SFX_CLICK, "SFX")
	get_tree().node_added.connect(_on_node_added)
	seed_player = _make_player(SFX_SEED, "SFX")
	water_player = _make_player(SFX_WATER, "SFX")
	harvest_player = _make_player(SFX_HARVEST, "SFX")
	_load_settings()
	
func _load_settings() -> void:
	_config.load(SETTINGS_PATH)
	_apply_bus("Music", get_music_volume())
	_apply_bus("SFX", get_sfx_volume())

func _make_player(stream: AudioStream, bus_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus_name
	add_child(player)
	return player

func _on_node_added(node: Node) -> void:
	if node is BaseButton and node is not Cell:
		node.button_down.connect(_play_click)

func _play_click() -> void:
	click_player.play()
	
func play_seed() -> void:
	seed_player.play()

func play_water() -> void:
	water_player.play()

func play_harvest() -> void:
	harvest_player.play()

func _apply_bus(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func get_music_volume() -> float:
	return _config.get_value("audio", "music", 1.0)

func get_sfx_volume() -> float:
	return _config.get_value("audio", "sfx", 1.0)

func set_music_volume(linear: float) -> void:
	_apply_bus("Music", linear)
	_config.set_value("audio", "music", linear)
	_config.save(SETTINGS_PATH)

func set_sfx_volume(linear: float) -> void:
	_apply_bus("SFX", linear)
	_config.set_value("audio", "sfx", linear)
	_config.save(SETTINGS_PATH)
