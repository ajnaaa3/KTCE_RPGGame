extends Attack

func execute(attacker : Character, defender : Character, attacker_anim : AnimationPlayer, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar,tree: SceneTree, statusBox: Panel):
	if randf() < self.accuracy:
		var stab : float = TypeInteractions.get_stab(self.type, attacker.type)
		var effective = TypeInteractions.get_effectiveness(self.type, defender.type)
		var random: float = randf_range(0.8, 1.2)
		var damage : int = round(max(0, ((self.power * float(attacker.current_attack) - float(defender.current_defense)) / 10) * effective * stab * random))
		defender.set_current_hp(max(0, defender.current_hp - damage))
		set_health(hpbar, defender.current_hp, defender.max_hp)
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
		await tree.create_timer(1.0).timeout
		match self.stat:
			Stat.ATTACK:
				attacker.set_current_attack(round(defender.current_attack * self.mod))
			Stat.DEFENSE:
				attacker.set_current_defense(round(defender.current_defense * self.mod))
			Stat.SPEED:
				attacker.set_current_speed(round(defender.current_speed * self.mod))
		defender_anim.play("debuff")
		defender_sound.stream = load("res://assets/sounds/Soundfx/stat_down.ogg")
		defender_sound.play()
		display_text(textbox, "%s lowered $s" % [attacker.name, defender.name] + "'s %s" % self.stat)
	else:
		display_text(textbox, "%s missed!" % attacker.name)
		
	
func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text	

func set_health(hpbar : ProgressBar, current_health : float, max_health: float):
	var newvalue: float = (current_health / max_health) * 100.0
	hpbar.value = newvalue
