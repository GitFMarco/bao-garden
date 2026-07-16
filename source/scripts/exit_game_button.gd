extends Button


func _ready() -> void:
	if OS.has_feature("web"):
		self.hide()

func _on_button_up() -> void:
	# Esci dal gioco -> chiudi la finestra
	get_tree().quit()
