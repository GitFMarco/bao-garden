class_name Cell
extends Button


var growth: float = 0.0

enum State {EMPTY, SEED, WATERED, SPROUT, MATURE}
const TEX_SOIL_DRY := preload("res://art/terrain.png")
const TEX_SOIL_WET := preload("res://art/wet-terrain.png")
const TEX_SEED := preload("res://art/seed.png")

var state: State = State.EMPTY
var crop: CropData = null

@onready var soil: TextureRect = $Soil
@onready var plant: TextureRect = $Plant

signal tapped(cell: Cell)

var row: int
var col: int


func _ready() -> void:
	pressed.connect(_on_pressed)
	set_state(State.EMPTY)
	
func _process(delta: float) -> void:
	if state != State.WATERED and state != State.SPROUT:
		return
	growth += delta
	if state == State.WATERED and growth >= crop.grow_time / 2.0:
		set_state(State.SPROUT)
	elif state == State.SPROUT and growth >= crop.grow_time:
		set_state(State.MATURE)
	
func _on_pressed() -> void:
	tapped.emit(self)
	
func set_state(new_state: State) -> void:
	state = new_state
	if new_state == State.EMPTY or new_state == State.SEED:
		growth = 0.0
	match state:
		State.EMPTY:
			soil.texture = TEX_SOIL_DRY
			plant.texture = null
		State.SEED:
			soil.texture = TEX_SOIL_DRY
			plant.texture = TEX_SEED
		State.WATERED:
			soil.texture = TEX_SOIL_WET
			plant.texture = TEX_SEED
		State.SPROUT:
			soil.texture = TEX_SOIL_WET
			plant.texture = crop.sprite_sprout
		State.MATURE:
			soil.texture = TEX_SOIL_DRY
			plant.texture = crop.sprite_mature
