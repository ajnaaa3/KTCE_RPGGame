extends Resource
class_name  Attack

@export var name : String = ""
@export var status : bool = false
@export var power : int = 10
@export var accuracy : float = 1.0
@export var stat : String = "attack"
@export var mod : float = 0.5
@export var type : Type.Type = Type.Type.NONE

func execute(attacker, defender, defender_anim : AnimationPlayer, defender_sound : AudioStreamPlayer, textbox : Panel, hpbar : ProgressBar):
	pass
