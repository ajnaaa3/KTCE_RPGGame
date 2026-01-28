extends Status

var bleedCount: int = 1

func execute(character: Character, anim : AnimationPlayer, textBox : Panel, hpbar : ProgressBar):
	if bleedCount == 1:
		bleedCount = 0
	elif bleedCount == 0:
		character.set_status(load("res://resources/Statuses/None.tres"))
		display_text(textBox, "%s" % character.name + "'s wounds are closing")
		bleedCount = 1
	elif bleedCount > 1:
		var newHP = character.current_hp - (character.max_hp * 0.2)
		display_text(textBox, "%s is bleeding!" % character.name)
		anim.play("damage")
		character.set_current_hp(newHP)
		set_health(hpbar, character.current_hp, character.max_hp)
	
func activate():
	bleedCount = 2

func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text

func set_health(hpbar : ProgressBar, current_health : float, max_health: float):
	var newvalue: float = (current_health / max_health) * 100.0
	hpbar.value = newvalue
