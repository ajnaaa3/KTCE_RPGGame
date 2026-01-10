extends HBoxContainer

signal member_selected(index : int)


@onready var buttons : Array[Node] = get_children()

func populate_members(party : Array[Character], currentCharacter : Character) :
	
	for i in range(buttons.size()):
		if currentCharacter == party[i]:
			buttons[i].text = "%s In Battle" % currentCharacter.name
			buttons[i].visible = true
			buttons[i].pressed.connect(on_current_party_member_selected)
		elif i < party.size():
			var character : Character = party[i]
			buttons[i].text = character.name
			buttons[i].visible = true
			buttons[i].pressed.connect(_on_member_selected.bind(i))
			
func on_current_party_member_selected():
	pass
func _on_member_selected(index : int):
	member_selected.emit(index)
