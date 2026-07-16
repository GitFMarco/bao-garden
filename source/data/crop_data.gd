class_name CropData
extends Resource

## Questa classe definisce le varie tipologie di semi di Bao.
## Con questo blueprint è possibile definire diverse tipologie di seme
## con proprietà diverse.

# Tipologie di bao attualmente possibili
enum Type {CLASSIC, HEART, STRAWBERRY, CAT, STAR, RAINBOW}

# -- Proprietà variabili -- #

# Tipo di Bao
@export var type: Type = Type.CLASSIC
# Nome visualizzato nella ui (shop, inventario, ecc...)
@export var display_name: String = ""
# Secondi che servono per passare dallo stato "watered" allo stato maturo (possibilità di essere raccolto)
@export var grow_time: float = 10.0
# Guadagno alla raccolta
@export var heart_reward: int = 1
# Prezzo nello shop (default zero per il seme CLASSIC)
@export var unlock_cost: int = 0
# Sbloccato ad inizio partita? (Es: il bao CLASSIC parte già sbloccato, quindi avrà true in questo campo)
@export var starts_unlocked: bool = false
# Sprite del germoglio
@export var sprite_sprout: Texture2D
# Sprite del bao maturo
@export var sprite_mature: Texture2D
