extends HBoxContainer

signal attack_selected(attack: Attack)

@onready var buttons = get_children()

var char : Character

func populate_moves(character : Character):
	char = character
	for i in range(buttons.size()):
		if i < character.moveset.size():
			var move = character.moveset[i]
			buttons[i].text = move.name
			buttons[i].visible = true
			buttons[i].pressed.connect(_on_move_selected.bind(i))

func _on_move_selected(index: int):
	var attack = char.moveset[index]
	attack_selected.emit(attack)
