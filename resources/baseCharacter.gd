extends Resource
class_name Character

enum Type {FIRE, WATER, AIR, EARTH}

@export var name: String = ""
@export var texture : Texture = null
@export var max_hp: int = 35
@export var attack: int = 5
@export var defense: int = 2
@export var speed: int = 3
@export var type : Type = Type.FIRE

@export var moveset : Array[Attack] = []
