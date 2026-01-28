extends Attack

func execute(attacker : Character, defender : Character, attacker_anim : AnimationPlayer, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar,tree: SceneTree, statusBox: Panel):
	attacker.set_current_attack(round(attacker.current_attack * self.mod))
	attacker.set_current_defense(round(attacker.current_defense * self.mod))
	attacker.set_current_speed(round(attacker.current_speed * self.mod))
	attacker_anim.play("buff")
	defender_sound.stream = load("res://assets/sounds/Soundfx/stat_up.ogg")
	display_text(textbox, "%s raised all his stats" % attacker.name)
	defender_sound.play()
	
func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text	
