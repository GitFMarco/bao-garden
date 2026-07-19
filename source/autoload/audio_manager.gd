extends Node


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


func _ready() -> void:
	music_player = _make_player(MUSIC, "Music")
	music_player.play()
	click_player = _make_player(SFX_CLICK, "SFX")
	get_tree().node_added.connect(_on_node_added)
	seed_player = _make_player(SFX_SEED, "SFX")
	water_player = _make_player(SFX_WATER, "SFX")
	harvest_player = _make_player(SFX_HARVEST, "SFX")

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
