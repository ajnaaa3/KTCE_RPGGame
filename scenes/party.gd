extends HBoxContainer

signal member_selected(index : int)


@onready var buttons : Array[Node] = get_children()

func populate_members(party: Array, currentCharacter: Character) -> void:
	for i in range(buttons.size()):
		buttons[i].visible = false

		if buttons[i].pressed.is_connected(_on_member_selected):
			buttons[i].pressed.disconnect(_on_member_selected)

		if buttons[i].pressed.is_connected(on_current_party_member_selected):
			buttons[i].pressed.disconnect(on_current_party_member_selected)

		if i >= party.size():
			continue

		var character: Character = party[i]

		buttons[i].visible = true
		buttons[i].text = character.name
		buttons[i].disabled = false

		if character == currentCharacter:
			buttons[i].text = "%s (In Battle)" % character.name
			buttons[i].disabled = true
			buttons[i].pressed.connect(on_current_party_member_selected)
		else:
			buttons[i].pressed.connect(_on_member_selected.bind(i))

		if character.current_hp <= 0:
			buttons[i].disabled = true


			
func on_current_party_member_selected():
	pass
func _on_member_selected(index : int):
	member_selected.emit(index)
