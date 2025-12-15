extends Resource
class_name Character

@export var name: String = ""
@export var texture : Texture = null
@export var max_hp: int = 35
@export var attack: int = 5
@export var defense: int = 2
@export var speed: int = 3
@export var type : Type.Type = Type.Type.FIRE
@export var moveset : Array[Attack] = []
@export var current_hp: int = 35 : set = set_current_hp

func _init():
	current_hp = max_hp

func set_current_hp(value: int):
	current_hp = clamp(value, 0, max_hp)
