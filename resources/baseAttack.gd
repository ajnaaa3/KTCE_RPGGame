extends Resource
class_name  Attack
enum Stat {ATTACK, DEFENSE, SPEED}

@export var name : String = ""
@export var power : int = 10
@export var accuracy : float = 1.0
@export var stat : Stat = Stat.ATTACK
@export var mod : float = 0.5
@export var type : Type.Type = Type.Type.NONE

func execute(attacker, defender, attacker_anim : AnimationPlayer, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar):
	pass
