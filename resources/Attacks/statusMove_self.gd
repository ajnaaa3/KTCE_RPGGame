extends Attack

func execute(attacker : Character, defender : Character, attacker_anim : AnimationPlayer, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar):
	if self.mod > 1 :
		match self.stat:
			Stat.ATTACK:
				attacker.set_current_attack(round(attacker.current_attack * self.mod))
				display_text(textbox, "%s raised its attack" % attacker.name)
			Stat.DEFENSE:
				attacker.set_current_defense(round(attacker.current_defense * self.mod))
				display_text(textbox, "%s raised its defense" % attacker.name)
			Stat.SPEED:
				attacker.set_current_speed(round(attacker.current_speed * self.mod))
				display_text(textbox, "%s raised its speed" % attacker.name)
		attacker_anim.play("buff")
		defender_sound.stream = load("res://assets/sounds/Soundfx/stat_up.ogg")
		defender_sound.play()
	
	if self.mod < 1 :
		match self.stat:
			Stat.ATTACK:
				attacker.set_current_attack(round(attacker.current_attack * self.mod))
			Stat.DEFENSE:
				attacker.set_current_defense(round(attacker.current_defense * self.mod))
			Stat.SPEED:
				attacker.set_current_speed(round(attacker.current_speed * self.mod))
		attacker_anim.play("debuff")
		defender_sound.stream = load("res://assets/sounds/Soundfx/stat_down.ogg")
		defender_sound.play()
		display_text(textbox, "%s lowered its %s" % [attacker.name, self.stat])
	

func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text	
