extends Button
class_name CharacterSlot

var character: Character

@onready var name_label: Label = $VBoxContainer/Label
@onready var icon_rect: TextureRect = $VBoxContainer/TextureRect

func set_character(c: Character) -> void:
	character = c
	name_label.text = c.name
	icon_rect.texture = c.texture
func _ready():
	mouse_entered.connect(func():
		scale = Vector2(1.03, 1.03)
	)
	mouse_exited.connect(func():
		scale = Vector2.ONE
	)

	
