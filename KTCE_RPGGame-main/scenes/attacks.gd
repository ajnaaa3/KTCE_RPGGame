extends HBoxContainer

signal attack_selected(attack: Attack)

@onready var buttons : Array[Node] = get_children()

var chara : Character

func populate_moves(character : Character):
	self.chara = character
	for i in range(buttons.size()):
		if i < character.moveset.size():
			var move: Attack = chara.moveset[i]
			buttons[i].text = move.name
			buttons[i].visible = true
			buttons[i].pressed.connect(_on_move_selected.bind(i))

func _on_move_selected(index: int):
	var attack: Attack = chara.moveset[index]
	attack_selected.emit(attack)
