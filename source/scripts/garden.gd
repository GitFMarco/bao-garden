extends Control


const CURSOR_SEED := preload("res://art/seed-packet.png")
const CURSOR_WATER := preload("res://art/watering_can.png")
const CURSOR_HARVEST := preload("res://art/chopsticks.png")

enum Mode {SEED, WATER, HARVEST}
var current_mode: Mode = Mode.SEED

var selected_crop: CropData.Type = CropData.Type.CLASSIC

const GRID_COLS := 5
const GRID_ROWS := 7

const CELL_SCENE: PackedScene = preload("res://scenes/cell.tscn")

@onready var _grid: GridContainer = %Grid


func _ready() -> void:
	# Bottoni topbar
	%MenuButton.pressed.connect(%MenuModal.show)
	%ShopButton.pressed.connect(%ShopModal.show)
	%BackpackButton.pressed.connect(_open_backpack)
	# Tap sul backdrop -> chiude la finestra
	for modal in [%MenuModal, %ShopModal, %BackpackModal]:
		modal.get_node("Backdrop").gui_input.connect(_on_modal_backdrop_input.bind(modal))

	# Inizializzo i cuori
	GameState.hearts_changed.connect(_on_hearts_changed)
	_on_hearts_changed(GameState.hearts)
	# Inizializzo il contatore dei semi
	GameState.seeds_changed.connect(_update_seed_button)
	_update_seed_button()
	# Inizializzo la bottom bar
	%SeedButton.pressed.connect(_set_mode.bind(Mode.SEED))
	%WaterButton.pressed.connect(_set_mode.bind(Mode.WATER))
	%HarvestButton.pressed.connect(_set_mode.bind(Mode.HARVEST))
	# Inizializziamo il puntatore con i semi
	_set_mode(current_mode)
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var cell: Cell = CELL_SCENE.instantiate()
			cell.row = row
			cell.col = col
			cell.tapped.connect(_on_cell_tapped)
			_grid.add_child(cell)
	if GameState.grid_data.size() == 35:
		apply_grid_data(GameState.grid_data)
			
func _save_now() -> void:
	GameState.grid_data = get_grid_data()
	GameState.save_game()

func _on_cell_tapped(cell: Cell) -> void:
	match current_mode:
		Mode.SEED:
			if cell.state == Cell.State.EMPTY and GameState.get_seed_count(selected_crop) > 0:
				GameState.add_seeds(selected_crop, -1)
				cell.crop = CropDatabase.get_crop(selected_crop)
				cell.set_state(Cell.State.SEED)
				_save_now()
		Mode.WATER:
			if cell.state == Cell.State.SEED:
				cell.set_state(Cell.State.WATERED)
				_save_now()
		Mode.HARVEST:
			if cell.state == Cell.State.MATURE:
				GameState.hearts += cell.crop.heart_reward
				GameState.add_seeds(cell.crop.type, 2)
				cell.crop = null
				cell.set_state(Cell.State.EMPTY)
				_save_now()
				print("Cuori totali: ", GameState.hearts)
				
func get_grid_data() -> Array:
	"""Celle -> Dati"""
	var cells_data: Array = []
	for cell: Cell in %Grid.get_children():
		var crop_type: int = -1
		if cell.crop != null:
			crop_type = cell.crop.type
		cells_data.append({
			"state": cell.state,
			"crop": crop_type,
			"growth": cell.growth
		})
	return cells_data
	
func apply_grid_data(cells_data: Array) -> void:
	"""Dati -> Celle"""
	var cells := %Grid.get_children()
	for i in cells_data.size():
		var cell: Cell = cells[i]
		var cell_data: Dictionary = cells_data[i]
		var crop_type := int(cell_data["crop"])
		if crop_type >= 0:
			cell.crop = CropDatabase.get_crop(crop_type as CropData.Type)
		cell.set_state(int(cell_data["state"]) as Cell.State)
		cell.growth = float(cell_data["growth"])

func _on_autosave_timer_timeout() -> void:
	_save_now()

func _on_hearts_changed(new_amount: int) -> void:
	%HeartsLabel.text = str(new_amount)
	
func _set_mode(mode: Mode) -> void:
	current_mode = mode
	match mode:
		Mode.SEED:
			Input.set_custom_mouse_cursor(CURSOR_SEED, Input.CURSOR_ARROW, Vector2(8, 8))
		Mode.WATER:
			Input.set_custom_mouse_cursor(CURSOR_WATER, Input.CURSOR_ARROW, Vector2(2, 6))
		Mode.HARVEST:
			Input.set_custom_mouse_cursor(CURSOR_HARVEST, Input.CURSOR_ARROW, Vector2(0, 0))

func _update_seed_button() -> void:
	%SeedCountLabel.text = str(GameState.get_seed_count(selected_crop))

func _on_modal_backdrop_input(event: InputEvent, modal: Control) -> void:
	if event is InputEventMouseButton and event.pressed:
		modal.hide()
		
func _open_backpack() -> void:
	_populate_backpack()
	%BackpackModal.show()
	
func _populate_backpack() -> void:
	# Svuota la lista dalla volta precedente
	for child in %CropList.get_children():
		child.queue_free()
		
	for crop in CropDatabase.get_all_crops():
		var row := Button.new()
		if crop.starts_unlocked:
			row.text = "%s  x%d" % [crop.display_name, GameState.get_seed_count(crop.type)]
			row.pressed.connect(_on_crop_selected.bind(crop.type))
		else:
			row.text = crop.display_name
			row.disabled = true
		row.custom_minimum_size.y = 48
		row.focus_mode = Control.FOCUS_NONE
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		%CropList.add_child(row)
		
func _on_crop_selected(type: CropData.Type) -> void:
	selected_crop = type
	_update_seed_button()
	%BackpackModal.hide()
