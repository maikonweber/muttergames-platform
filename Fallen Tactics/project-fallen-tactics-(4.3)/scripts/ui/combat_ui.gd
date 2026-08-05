extends CanvasLayer
## Minimal combat HUD: hand, timeline, log, end turn.

@onready var combat: CombatManager = get_parent()
@onready var hand_box: HBoxContainer = $Root/Bottom/Hand
@onready var energy_label: Label = $Root/Bottom/InfoRow/EnergyLabel
@onready var stance_label: Label = $Root/Bottom/InfoRow/StanceLabel
@onready var turn_label: Label = $Root/Top/TurnLabel
@onready var timeline_label: Label = $Root/Top/TimelineLabel
@onready var log_label: RichTextLabel = $Root/Side/Log
@onready var end_turn_btn: Button = $Root/Bottom/InfoRow/EndTurnBtn
@onready var reward_panel: PanelContainer = $Root/RewardPanel
@onready var reward_box: VBoxContainer = $Root/RewardPanel/Margin/VBox/Rewards
@onready var title_label: Label = $Root/Top/TitleLabel
@onready var help_label: Label = $Root/Bottom/HelpLabel


func _ready() -> void:
	combat.hand_changed.connect(refresh_hand)
	combat.timeline_changed.connect(refresh_timeline)
	combat.turn_changed.connect(_on_turn)
	combat.log_message.connect(_on_log)
	combat.combat_ended.connect(_on_combat_ended)
	end_turn_btn.pressed.connect(_on_end_turn)
	reward_panel.visible = false
	_on_log("Project Fallen Tactics — Vertical Slice")
	_on_log("Clique cartas → escolha tile/inimigo. Espaço = fim do turno. Esc = cancelar.")
	refresh_hand()
	refresh_timeline()


func refresh_hand() -> void:
	for c in hand_box.get_children():
		c.queue_free()
	var hero := combat.get_hero()
	if hero == null:
		energy_label.text = "HP —"
		stance_label.text = ""
		return
	energy_label.text = "⚡ %d/%d   ❤ %d/%d" % [hero.energy, hero.max_energy, hero.hp, hero.max_hp]
	stance_label.text = "Postura: %s" % hero.stance
	if combat.active_unit != hero or combat.phase == CombatManager.Phase.ENDED:
		return
	for i in hero.hand.size():
		var id: String = hero.hand[i]
		var def := CardLibrary.get_card(id)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(118, 96)
		btn.text = "%s\n[%d] %s" % [def.display_name, def.cost, _type_short(def)]
		btn.tooltip_text = def.description
		var idx := i
		btn.pressed.connect(func(): combat.select_card(idx))
		# Color by type
		match def.card_type:
			CardDef.CardType.ATTACK:
				btn.modulate = Color("ffb4a8")
			CardDef.CardType.DEFENSE:
				btn.modulate = Color("a8c8ff")
			CardDef.CardType.MOVEMENT:
				btn.modulate = Color("a8ffc8")
			CardDef.CardType.CONTROL:
				btn.modulate = Color("e0a8ff")
			CardDef.CardType.SPECIAL:
				btn.modulate = Color("ffe08a")
			_:
				btn.modulate = Color.WHITE
		if hero.energy < def.cost:
			btn.disabled = true
			btn.modulate = btn.modulate.darkened(0.4)
		hand_box.add_child(btn)


func _type_short(def: CardDef) -> String:
	match def.card_type:
		CardDef.CardType.ATTACK:
			return "ATK"
		CardDef.CardType.DEFENSE:
			return "DEF"
		CardDef.CardType.MOVEMENT:
			return "MOV"
		CardDef.CardType.CONTROL:
			return "CTL"
		CardDef.CardType.BUFF:
			return "BUF"
		CardDef.CardType.DEBUFF:
			return "DEB"
		_:
			return "ESP"


func refresh_timeline() -> void:
	var parts: PackedStringArray = []
	var sorted: Array[BattleUnit] = []
	for u in combat.units:
		if u.alive:
			sorted.append(u)
	sorted.sort_custom(func(a: BattleUnit, b: BattleUnit): return a.timeline_value < b.timeline_value)
	for u in sorted:
		var mark := "▶" if u == combat.active_unit else "·"
		var side := "P" if u.is_player else "E"
		parts.append("%s %s(%s):%d" % [mark, u.display_name, side, u.timeline_value])
	timeline_label.text = "Timeline: " + "  |  ".join(parts)


func _on_turn(unit: BattleUnit) -> void:
	if unit:
		turn_label.text = "Turno: %s" % unit.display_name
	refresh_hand()
	refresh_timeline()


func _on_log(text: String) -> void:
	log_label.append_text(str(text) + "\n")


func _on_end_turn() -> void:
	combat.end_player_turn()


func _on_combat_ended(won: bool) -> void:
	refresh_hand()
	if won:
		if GameState.encounter_index >= 3:
			_on_log("Run completa! Boss derrotado. Reinicie a cena para nova run.")
			title_label.text = "VITÓRIA TOTAL"
			return
		_show_rewards()
	else:
		title_label.text = "DERROTA"
		help_label.text = "F5 ou recarregue a cena para tentar de novo."


func _show_rewards() -> void:
	reward_panel.visible = true
	for c in reward_box.get_children():
		c.queue_free()
	var pool := combat.offer_rewards()
	pool.shuffle()
	var picks: Array[String] = []
	for i in mini(3, pool.size()):
		picks.append(pool[i])
	var lbl := Label.new()
	lbl.text = "Escolha 1 carta de recompensa:"
	reward_box.add_child(lbl)
	for id in picks:
		var def := CardLibrary.get_card(id)
		var btn := Button.new()
		btn.text = "%s — %s" % [def.display_name, def.description]
		btn.pressed.connect(_on_pick_reward.bind(id))
		reward_box.add_child(btn)
	var skip := Button.new()
	skip.text = "Pular recompensa"
	skip.pressed.connect(_on_pick_reward.bind(""))
	reward_box.add_child(skip)


func _on_pick_reward(card_id: String) -> void:
	if card_id != "":
		GameState.add_card_reward(card_id)
		_on_log("Carta adicionada: %s" % card_id)
	reward_panel.visible = false
	# Next fight
	combat.start_encounter(GameState.next_encounter())
	title_label.text = "Project Fallen Tactics"
	refresh_hand()
	refresh_timeline()
