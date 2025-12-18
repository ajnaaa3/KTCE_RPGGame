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
@export var current_attack: int = 5
@export var current_defense: int = 2
@export var current_speed: int = 3
func _init():
	current_hp = max_hp
	current_attack = attack
	current_defense = defense
	current_speed = speed

func set_current_hp(value: int):
	current_hp = clamp(value, 0, max_hp)

func set_current_attack(value: int):
	current_attack = max(1, value)

func set_current_defense(value: int):
	current_defense = max(1, value)

func set_current_speed(value: int):
	current_speed = max(1, value)
