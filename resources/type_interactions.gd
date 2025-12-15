extends Resource

class_name TypeInteractions

static func get_effectiveness(attack_type : Type.Type, defender_type : Type.Type):
	match attack_type:
		Type.Type.FIRE:
			match defender_type:
				Type.Type.FIRE:
					return 0.5
				Type.Type.WATER:
					return 0.5
				Type.Type.EARTH:
					return 2.0
		Type.Type.EARTH:
			match defender_type:
				Type.Type.FIRE:
					return 0.5
				Type.Type.WATER:
					return 2.0
				Type.Type.EARTH:
					return 0.5
		Type.Type.WATER:
			match defender_type:
				Type.Type.FIRE:
					return 2.0
				Type.Type.WATER:
					return 0.5
				Type.Type.EARTH:
					return 0.5
	return 1.0
	
static func get_stab (attack_type : Type.Type, attacker_type : Type.Type):
	if attack_type == attacker_type: 
		return 1.5
	return 1.0
