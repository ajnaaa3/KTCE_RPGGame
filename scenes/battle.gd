extends Node2D
class_name Battle

signal textbox_closed

@export var playersParty : Array[Character]
@export var enemiesParty : Array[Character]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_attack: Attack
var enemy_attack: Attack
enum BattleState { PLAYER_TURN, ENEMY_TURN, RESOLVE_ATTACKS, PLAYER_WIN, PLAYER_LOSE}
var current_state: BattleState = BattleState.PLAYER_TURN
var victory_music: String = "res://assets/sounds/victory.ogg" 
var defeat_music: String = "res://assets/sounds/defeat.ogg" 

@onready var current_hpbar : ProgressBar = $%PlayerHPBar
@onready var attack_panel: HBoxContainer = $PlayerPanel/Attacks
@onready var party_panel: HBoxContainer = $PlayerPanel/Party
@onready var player_anim: AnimationPlayer = $PlayerContainer/CharacterAnimationPlayer
@onready var enemy_anim: AnimationPlayer = $EnemyContainer/CharacterAnimationPlayer
@onready var music_player : AudioStreamPlayer = $BGMPlayer
@onready var soundfx_player : AudioStreamPlayer = $SoundFXPlayer
@onready var switch_button: Button = $PlayerPanel/SwitchButton
@onready var playerParty : Array[Character] = playersParty.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
@onready var enemyParty : Array[Character] = enemiesParty.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
@onready var selectedPlayer : Character = playerParty[0]
@onready var selectedEnemy : Character = enemyParty[0]
@onready var newPlayerCharacter : Character = selectedPlayer
@onready var newEnemyCharacter : Character = selectedEnemy

func _ready() -> void:
	for member in playerParty:
		member.set_current_hp(member.max_hp)
		member.set_current_attack(member.attack)
		member.set_current_defense(member.defense)
		member.set_current_speed(member.speed)
	for member in enemyParty:
		member.set_current_hp(member.max_hp)
		member.set_current_attack(member.attack)
		member.set_current_defense(member.defense)
		member.set_current_speed(member.speed)
	set_health($PlayerContainer/PlayerHPBar, selectedPlayer.current_hp, selectedPlayer.max_hp)
	set_health($EnemyContainer/EnemyHPBar, selectedEnemy.current_hp, selectedEnemy.max_hp)
	$PlayerContainer/Sprite.texture = selectedPlayer.texture
	$EnemyContainer/Sprite.texture = selectedEnemy.texture
	$EnemyContainer/Name.text = selectedEnemy.name
	$PlayerContainer/Name.text = selectedPlayer.name
	party_panel.visible = false
	party_panel.populate_members(playerParty, selectedPlayer)
	party_panel.member_selected.connect(_on_player_switch_selected)
	attack_panel.populate_moves(selectedPlayer)
	attack_panel.attack_selected.connect(_on_player_attack_selected)
	switch_button.pressed.connect(_on_switch_button)
	
	$Textbox.hide()
	$PlayerPanel.hide()
	display_text($Textbox, "A wild %s appears" % selectedEnemy.name)
	await(textbox_closed)
	transition_to(current_state)

func display_text(panel_node : Panel, text : String):
	panel_node.show()
	panel_node.get_node("Label").text = text
	
func _on_switch_button() -> void:
	attack_panel.visible = not attack_panel.visible
	party_panel.visible = not party_panel.visible

func _input(event: InputEvent) -> void:
	if(current_state == BattleState.PLAYER_TURN 
		or current_state == BattleState.PLAYER_WIN 
		or current_state == BattleState.PLAYER_LOSE) \
		and (Input.is_action_just_pressed("ui_accept") 
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$Textbox.hide()
		emit_signal("textbox_closed")
		

func set_health(hpbar_node, current_health : float, max_health : float):
	hpbar_node.value = (current_health / max_health) * 100.0
	
func _on_player_attack_selected(attack: Attack) -> void:
	player_attack = attack
	$PlayerPanel.hide()
	transition_to(BattleState.ENEMY_TURN)
	
func _on_player_switch_selected(index : int):
	newPlayerCharacter = playerParty[index]
	$PlayerPanel.hide()
	transition_to(BattleState.ENEMY_TURN)
	
func transition_to(new_state: BattleState) -> void:
	current_state = new_state
	match current_state:
		BattleState.PLAYER_TURN:
			$Textbox.hide()
			party_panel.visible = false
			attack_panel.visible = true
			$PlayerPanel.show()
			
		BattleState.ENEMY_TURN:
			display_text($Textbox, "Waiting for %s's move" % selectedEnemy.name)
			await get_tree().create_timer(1.0).timeout
			enemy_attack = selectedEnemy.moveset[rng.randi_range(0, selectedEnemy.moveset.size() - 1)]
			transition_to(BattleState.RESOLVE_ATTACKS)
			
		BattleState.RESOLVE_ATTACKS:
			var check = selectedPlayer == newPlayerCharacter
			if selectedPlayer != newPlayerCharacter:
				player_anim.play("defeat")
				soundfx_player.stream = load("res://assets/sounds/Soundfx/switch.ogg")
				soundfx_player.play()
				await character_switch(true)
				await enemy_attack.execute(selectedEnemy, selectedPlayer, enemy_anim, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedPlayer.current_hp < 1 :
					character_down(selectedPlayer, playerParty, true)
					return
					
			elif (selectedPlayer.current_speed > selectedEnemy.current_speed):
				display_text($Textbox, "%s uses %s" % [selectedPlayer.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(selectedPlayer, selectedEnemy,player_anim, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedEnemy.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedEnemy, enemyParty, false)
					return
				current_hpbar = %PlayerHPBar
				display_text($Textbox, "%s uses %s" % [selectedEnemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(selectedEnemy, selectedPlayer, enemy_anim, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedPlayer.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedPlayer, playerParty, true)
					return
				
			elif (selectedPlayer.current_speed < selectedEnemy.current_speed):
				display_text($Textbox, "%s uses %s" % [selectedEnemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(selectedEnemy, selectedPlayer, enemy_anim, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedPlayer.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedPlayer, playerParty, true)
					return
				display_text($Textbox, "%s uses %s" % [selectedPlayer.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(selectedPlayer, selectedEnemy, player_anim, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedEnemy.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedEnemy, enemyParty, false)
					return
				
			elif (rng.randi_range(0, 100) < 50):
				display_text($Textbox, "%s uses %s" % [selectedPlayer.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(selectedPlayer, selectedEnemy, player_anim, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedEnemy.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedEnemy, enemyParty, false)
					return
				display_text($Textbox, "%s uses %s" % [selectedEnemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(selectedEnemy, selectedPlayer, enemy_anim, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedPlayer.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedPlayer, playerParty, true)
					return
				
			else:
				display_text($Textbox, "%s uses %s" % [selectedEnemy.name, enemy_attack.name])
				await get_tree().create_timer(1.0).timeout
				await enemy_attack.execute(selectedEnemy, selectedPlayer, enemy_anim, player_anim, soundfx_player, $Textbox, %PlayerHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedPlayer.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedPlayer, playerParty, true)
					return
				display_text($Textbox, "%s uses %s" % [selectedPlayer.name, player_attack.name])
				await get_tree().create_timer(1.0).timeout
				await player_attack.execute(selectedPlayer, selectedEnemy, player_anim, enemy_anim, soundfx_player, $Textbox, %EnemyHPBar)
				await get_tree().create_timer(1.3).timeout
				if selectedEnemy.current_hp < 1 :
					if battle_end() :
						return
					character_down(selectedEnemy, enemyParty, false)
					return
				
			await get_tree().create_timer(1.0).timeout
			transition_to(BattleState.PLAYER_TURN)
			
		BattleState.PLAYER_WIN:
			enemy_anim.play("defeat")
			soundfx_player.stream = load("res://assets/sounds/Soundfx/downed.wav")
			soundfx_player.play()
			await get_tree().create_timer(0.7).timeout
			music_player.stop()
			music_player.stream = load(victory_music)
			music_player.play()
			display_text($Textbox, "You won!")
			await(textbox_closed)
			get_tree().set_meta("battle_result", "win")
			call_deferred("deferred_goto_results")
			
		BattleState.PLAYER_LOSE:
			player_anim.play("defeat")
			soundfx_player.stream = load("res://assets/sounds/Soundfx/downed.wav")
			soundfx_player.play()
			await get_tree().create_timer(0.7).timeout
			music_player.stop()
			music_player.stream = load(defeat_music)
			music_player.play()
			display_text($Textbox, "You lost...")
			await(textbox_closed)
			get_tree().set_meta("battle_result", "lost")
			call_deferred("deferred_goto_results")
	

func battle_end() -> bool:
	var allDefeated : bool = true
	for member in playerParty:
		if member.current_hp > 0:
			allDefeated = false
			break
	if allDefeated:
		transition_to(BattleState.PLAYER_LOSE)
		return true
		
	allDefeated = true
	for member in enemyParty:
		if member.current_hp > 0:
			allDefeated = false
			break
	if allDefeated:
		transition_to(BattleState.PLAYER_WIN)
		return true
	return false
		

func character_switch(isPlayer : bool):
	if isPlayer:
		if selectedPlayer.current_hp > 0:
			display_text($Textbox, "%s is out" % selectedPlayer.name)
			await get_tree().create_timer(1.0).timeout
		selectedPlayer = newPlayerCharacter
		set_health($PlayerContainer/PlayerHPBar, selectedPlayer.current_hp, selectedPlayer.max_hp)
		$PlayerContainer/Sprite.texture = selectedPlayer.texture
		$PlayerContainer/Name.text = selectedPlayer.name
		party_panel.populate_members(playerParty, selectedPlayer)
		party_panel.member_selected.connect(_on_player_switch_selected)
		attack_panel.populate_moves(selectedPlayer)
		attack_panel.attack_selected.connect(_on_player_attack_selected)
		switch_button.pressed.connect(_on_switch_button)
		player_anim.play("switch_in")
		soundfx_player.stream = load("res://assets/sounds/Soundfx/switch_in.ogg")
		soundfx_player.play()
		display_text($Textbox, "%s is in" % selectedPlayer.name)
		await get_tree().create_timer(1.0).timeout
	else:
		if selectedEnemy.current_hp > 0:
			display_text($Textbox, "%s is out" % selectedEnemy.name)
			await get_tree().create_timer(1.0).timeout
		selectedEnemy = newEnemyCharacter
		set_health($EnemyContainer/EnemyHPBar, selectedEnemy.current_hp, selectedEnemy.max_hp)
		$EnemyContainer/Sprite.texture = selectedEnemy.texture
		$EnemyContainer/Name.text = selectedEnemy.name
		enemy_anim.play("switch_in")
		soundfx_player.stream = load("res://assets/sounds/Soundfx/switch_in.ogg")
		soundfx_player.play()
		display_text($Textbox, "%s is in" % selectedEnemy.name)
		await get_tree().create_timer(1.0).timeout
	
func character_down(character : Character, party : Array[Character], isPlayer : bool):
	if isPlayer:
		player_anim.play("defeat")
	else:
		enemy_anim.play("defeat")
	soundfx_player.stream = load("res://assets/sounds/Soundfx/downed.wav")
	soundfx_player.play()
	display_text($Textbox, "%s was defeated" % character.name)
	await get_tree().create_timer(1.0).timeout
	for member in party :
		if member.current_hp > 0:
			if isPlayer:
				newPlayerCharacter = member
			else:
				newEnemyCharacter = member
			await character_switch(isPlayer)
			transition_to(BattleState.PLAYER_TURN)
			return
	
func deferred_goto_results():
	get_tree().change_scene_to_file("res://scenes/result.tscn")
