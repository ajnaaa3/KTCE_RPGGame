extends Node

var music_enabled: bool = true
var sfx_enabled: bool = true
var game_mode: int = 4
var playersParty: Array[Character] = []
var enemiesParty: Array[Character] = []
const ALL_CHARACTERS: Array[Character] = [
	preload("res://resources/Characters/Eviath.tres"), 
	preload("res://resources/Characters/gumbotron.tres"), 
	preload("res://resources/Characters/HotStick.tres"), 
	preload("res://resources/Characters/Ithrit.tres"),
	preload("res://resources/Characters/Krabble.tres"),
	preload("res://resources/Characters/lilGuy.tres"),
	preload("res://resources/Characters/TickTick.tres"),
	preload("res://resources/Characters/Urgaid.tres")
]

func set_music(value: bool):
	music_enabled = value
	if not music_enabled:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		
func set_sfx(value: bool):
	sfx_enabled = value
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
			AudioServer.set_bus_mute(bus_idx, !value)
