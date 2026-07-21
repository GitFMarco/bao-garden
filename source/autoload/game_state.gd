extends Node


const SAVE_PATH := "user://save.json"

# CROP SBLOCCATI
signal unlocks_changed
var unlocked_crops: Array = [CropData.Type.CLASSIC]

# VALUTA DEL GIOCO
signal hearts_changed(new_amount: int)
# Setter che emette un segnale ogni qualvolta cambia la variabile hearts (tipo la onchange di Odoo)
var hearts: int = 0:
	set(value):
		hearts = value
		hearts_changed.emit(hearts)

var grid_data: Array = []

# INVENTARIO DEI SEMI
signal seeds_changed
# Mappatura tipo di crop -> quantità posseduta
var seeds: Dictionary = {CropData.Type.CLASSIC: 5}


func _ready() -> void:
	load_game()
	
func save_game() -> void:
	var data := {
		"hearts": hearts,
		"grid": grid_data,
		"seeds": seeds,
		"unlocks": unlocked_crops
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if data == null:
		return
	hearts = int(data.get("hearts", 0))
	grid_data = data.get("grid", [])
	var loaded_seeds: Dictionary = data.get("seeds", {})
	if not loaded_seeds.is_empty():
		# Qui è necessaria la conversione in intero delle chiavi, perchè durante il salvataggio
		# in JSON, le chiavi vengono convertite in automatico in stringhe dalla convenzione
		seeds = {}
		for key in loaded_seeds:
			seeds[int(key)] = int(loaded_seeds[key])
	# Faccio la stessa conversione che ho fatto per le chiavi dei semi, dovuta alla convenzione JSON
	var loaded_unlocks: Array = data.get("unlocks", [])
	if not loaded_unlocks.is_empty():
		unlocked_crops = []
		for u in loaded_unlocks:
			unlocked_crops.append(int(u))
			
func delete_save() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	hearts = 0
	seeds = {CropData.Type.CLASSIC: 5}
	seeds_changed.emit()
	grid_data = []
	unlocked_crops = [CropData.Type.CLASSIC]
	unlocks_changed.emit()
	
func get_seed_count(type: CropData.Type) -> int:
	return int(seeds.get(type, 0))

func add_seeds(type: CropData.Type, amount: int) -> void:
	seeds[type] = get_seed_count(type) + amount
	seeds_changed.emit()
	
func is_unlocked(type: CropData.Type) -> bool:
	return unlocked_crops.has(type)
	
func unlock_crop(type: CropData.Type) -> void:
	if is_unlocked(type):
		# Non fare nulla se è già sbloccato
		return
	unlocked_crops.append(type)
	unlocks_changed.emit()
