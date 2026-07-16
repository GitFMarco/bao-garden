extends Node


const _CROP_PATHS: Array[String] = [
	"res://data/crops/classic.tres",
	"res://data/crops/heart.tres",
	"res://data/crops/strawberry.tres",
	"res://data/crops/cat.tres",
	"res://data/crops/star.tres",
	"res://data/crops/rainbow.tres"
]

# CropData.Type -> CropData
var _crops: Dictionary = {}


func _ready() -> void:
	for path in _CROP_PATHS:
		var crop: CropData = load(path)
		_crops[crop.type] = crop
	print("CropDatabase: caricati %d crop" % _crops.size())


func get_crop(type: CropData.Type) -> CropData:
	return _crops[type]


func get_all_crops() -> Array[CropData]:
	var result: Array[CropData] = []
	for crop in _crops.values():
		result.append(crop)
	return result
