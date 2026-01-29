extends HBoxContainer

signal member_selected(index : int)

var buttons: Array[Button] = []

func populate_members(party: Array, currentCharacter: Character) -> void:
	for btn in buttons:
		remove_child(btn)
		btn.queue_free()
		if btn.is_connected("pressed", _on_member_selected):
			btn.pressed.disconnect(_on_member_selected)
		if btn.is_connected("pressed", on_current_party_member_selected):
			btn.pressed.disconnect(on_current_party_member_selected)
	buttons.clear()
	
	for i in range(party.size()):
		var character: Character = party[i]
		var btn = Button.new()
		
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(100, 40)
		
		btn.text = character.name
		btn.disabled = (character == currentCharacter) or (character.current_hp <= 0)
		
		if character == currentCharacter:
			btn.text += " (In Battle)"
			btn.pressed.connect(on_current_party_member_selected)
		else:
			btn.pressed.connect(_on_member_selected.bind(i))
		
		add_child(btn)
		buttons.append(btn)

			
func on_current_party_member_selected():
	pass
func _on_member_selected(index : int):
	member_selected.emit(index)
