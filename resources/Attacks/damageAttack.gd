extends Attack

func execute(attacker : Character, defender : Character, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar):
	if randf() < self.accuracy:
		var stab : float = TypeInteractions.get_stab(self.type, attacker.type)
		var effective = TypeInteractions.get_effectiveness(self.type, defender.type)
		var random: float = randf_range(0.8, 1.2)
		var damage : int = round(max(0, ((self.power * float(attacker.attack) - float(defender.defense)) / 10) * effective * stab * random))
		defender.set_current_hp(defender.current_hp - damage)
		set_health(hpbar, defender.current_hp)
		defender_anim.play("damage")
		if effective == 2.0:
			defender_sound.stream = load("res://assets/sounds/Soundfx/hit_super_effective.ogg")
			defender_sound.play()
		elif effective == 1.0:
			defender_sound.stream = load("res://assets/sounds/Soundfx/hit.ogg")
			defender_sound.play()
		else:
			defender_sound.stream = load("res://assets/sounds/Soundfx/hit_weak.ogg")
			defender_sound.play()
		display_text(textbox, "%s takes %d damage!" % [defender.name, damage])
	else:
		display_text(textbox, "%s missed!" % attacker.name)
		
	
func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text	

func set_health(hpbar : ProgressBar, current_health : int):
	hpbar.value = current_health
