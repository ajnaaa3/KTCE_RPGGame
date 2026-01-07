extends Resource
class_name Character

@export var name: String = ""
@export var texture: Texture
@export var max_hp: int = 35
@export var attack: int = 5
@export var defense: int = 2
@export var speed: int = 3
@export var type: Type.Type = Type.Type.FIRE
@export var moveset: Array[Attack] = []

@export var current_hp: int = 35 : set = set_current_hp
@export var current_attack: int = 5
@export var current_defense: int = 2
@export var current_speed: int = 3

# =========================
#   STATUS & COMBAT STATE
# =========================

var statuses: Array = []              # Burned, Bleeding, etc.
var next_attack_miss_chance: float = 0.0  # für Confused
var slash_hit_streak: int = 0         # für Bleeding

func _init():
	current_hp = max_hp
	current_attack = attack
	current_defense = defense
	current_speed = speed

# =========================
#   SETTER
# =========================

func set_current_hp(value: int):
	current_hp = clamp(value, 0, max_hp)

func set_current_attack(value: int):
	current_attack = max(1, value)

func set_current_defense(value: int):
	current_defense = max(1, value)

func set_current_speed(value: int):
	current_speed = max(1, value)

# =========================
#   COMBAT HELPERS
# =========================

func apply_damage(amount: int) -> void:
	current_hp = clamp(current_hp - amount, 0, max_hp)

func heal(amount: int) -> void:
	current_hp = clamp(current_hp + amount, 0, max_hp)

# =========================
#   STATUS HANDLING
# =========================

func add_status(status) -> void:
	# keine Duplikate
	for s in statuses:
		if s.id == status.id:
			return
	statuses.append(status)

func remove_status(id: String) -> void:
	statuses = statuses.filter(func(s): return s.id != id)

func process_statuses_end_of_turn() -> void:
	for s in statuses:
		s.on_turn_end(self)

# =========================
#   CONFUSED CHECK
# =========================

func check_confused_miss() -> bool:
	if next_attack_miss_chance > 0.0:
		if randf() < next_attack_miss_chance:
			next_attack_miss_chance = 0.0
			return true
		next_attack_miss_chance = 0.0
	return false
