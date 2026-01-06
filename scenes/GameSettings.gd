extends Node

var music_enabled: bool = true
var sfx_enabled: bool = true
var game_mode: String = "Versus PC"

func set_music(value: bool):
	music_enabled = value
	if not music_enabled:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
