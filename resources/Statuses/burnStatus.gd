extends Status

func execute(character: Character, anim : AnimationPlayer, textBox : Panel, hpbar : ProgressBar):
	var newHP = character.current_hp - (character.max_hp * 0.15)
	display_text(textBox, "%s is burning!" % character.name)
	anim.play("damage")
	character.set_current_hp(newHP)
	set_health(hpbar, character.current_hp, character.max_hp)

func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text

func set_health(hpbar : ProgressBar, current_health : float, max_health: float):
	var newvalue: float = (current_health / max_health) * 100.0
	hpbar.value = newvalue
