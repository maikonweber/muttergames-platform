extends CanvasLayer
## Combat HUD: hand of active hero, party strip, timeline, rewards with hero pick.

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

var _party_row: HBoxContainer
var _pending_reward_card: String = ""


func _ready() -> void:
	combat.hand_changed.connect(refresh_hand)
	combat.timeline_changed.connect(refresh_timeline)
	combat.turn_changed.connect(_on_turn)
	combat.log_message.connect(_on_log)
	combat.combat_ended.connect(_on_combat_ended)
	end_turn_btn.pressed.connect(_on_end_turn)
	reward_panel.visible = false
	_ensure_party_row()
	_on_log("Project Fallen Tactics — Campo amplo + FOW + party 3")
	_on_log("Um só modo: combate tático. Explore o mapa com movimento. FOW revela inimigos.")
	_on_log("Cada herói joga no seu turno. Espaço = fim do turno.")
	refresh_hand()
	refresh_timeline()
	refresh_party_strip()


func _ensure_party_row() -> void:
	if _party_row != null and is_instance_valid(_party_row):
		return
	_party_row = HBoxContainer.new()
	_party_row.name = "PartyRow"
	_party_row.add_theme_constant_override("separation", 8)
	# Insert above help in bottom
	var bottom: VBoxContainer = $Root/Bottom
	bottom.add_child(_party_row)
	bottom.move_child(_party_row, 0)


func refresh_party_strip() -> void:
	_ensure_party_row()
	for c in _party_row.get_children():
		c.queue_free()
	for u in combat.units:
		if not u.is_player:
			continue
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 36)
		var mark := "▶ " if u == combat.active_unit else ""
		var dead := " (X)" if not u.alive else ""
		btn.text = "%s%s %d/%d%s" % [mark, u.display_name, u.hp, u.max_hp, dead]
		btn.disabled = not u.alive
		if u == combat.active_unit:
			btn.modulate = Color("ffe08a")
		elif u.is_player:
			btn.modulate = Color("8ec8ff")
		_party_row.add_child(btn)


func refresh_hand() -> void:
	for c in hand_box.get_children():
		c.queue_free()
	refresh_party_strip()
	var hero := combat.active_unit if (combat.active_unit and combat.active_unit.is_player) else combat.get_hero()
	if hero == null:
		energy_label.text = "Party —"
		stance_label.text = ""
		return
	energy_label.text = "%s  ⚡ %d/%d   ❤ %d/%d" % [
		hero.display_name, hero.energy, hero.max_energy, hero.hp, hero.max_hp
	]
	var stance_txt := "Equilíbrio"
	match hero.stance:
		"guard":
			stance_txt = "🛡 Guarda"
		"offense":
			stance_txt = "⚔ Ofensiva"
		_:
			stance_txt = "◆ Equilíbrio"
	if hero.prepared_reaction == "parry":
		stance_txt += " · ✋ Parry"
	stance_label.text = "Postura: %s" % stance_txt
	if combat.active_unit != hero or not hero.is_player or combat.phase == CombatManager.Phase.ENDED:
		return
	if combat.phase != CombatManager.Phase.PLAYER_TURN and combat.phase != CombatManager.Phase.SELECT_TARGET:
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
		var side := "HERÓI" if unit.is_player else "INIMIGO"
		turn_label.text = "Turno: %s  [%s]" % [unit.display_name, side]
		turn_label.modulate = Color("8ec8ff") if unit.is_player else Color("ff8a7a")
	refresh_hand()
	refresh_timeline()
	refresh_party_strip()


func _on_log(text: String) -> void:
	log_label.append_text(str(text) + "\n")


func _on_end_turn() -> void:
	var ab := get_node_or_null("/root/AudioBus")
	if ab and ab.has_method("ui_click"):
		ab.ui_click()
	combat.end_player_turn()


func _on_combat_ended(won: bool) -> void:
	refresh_hand()
	refresh_party_strip()
	if won:
		if GameState.encounter_index >= 3:
			_on_log("Run completa! Boss derrotado. Reinicie a cena (F5) para nova run.")
			title_label.text = "VITÓRIA TOTAL"
			return
		_show_rewards()
	else:
		title_label.text = "DERROTA"
		help_label.text = "F5 ou recarregue a cena para tentar de novo."


func _show_rewards() -> void:
	reward_panel.visible = true
	_pending_reward_card = ""
	for c in reward_box.get_children():
		c.queue_free()
	var pool := combat.offer_rewards()
	pool.shuffle()
	var picks: Array[String] = []
	for i in mini(3, pool.size()):
		picks.append(pool[i])
	var lbl := Label.new()
	lbl.text = "Escolha 1 carta, depois o herói que a recebe:"
	reward_box.add_child(lbl)
	for id in picks:
		var def := CardLibrary.get_card(id)
		var btn := Button.new()
		btn.text = "%s — %s" % [def.display_name, def.description]
		btn.pressed.connect(_on_pick_reward_card.bind(id))
		reward_box.add_child(btn)
	var skip := Button.new()
	skip.text = "Pular recompensa"
	skip.pressed.connect(_on_pick_reward_card.bind(""))
	reward_box.add_child(skip)


func _on_pick_reward_card(card_id: String) -> void:
	var ab := get_node_or_null("/root/AudioBus")
	if ab and ab.has_method("reward"):
		ab.reward()
	if card_id == "":
		_finish_reward()
		return
	_pending_reward_card = card_id
	# Replace panel content with hero pick
	for c in reward_box.get_children():
		c.queue_free()
	var lbl := Label.new()
	lbl.text = "Quem recebe: %s ?" % CardLibrary.get_card(card_id).display_name
	reward_box.add_child(lbl)
	for i in GameState.party.size():
		var hs: Dictionary = GameState.party[i]
		var btn := Button.new()
		btn.text = "%s (%s)" % [str(hs.get("display_name", "?")), str(hs.get("class_id", ""))]
		btn.pressed.connect(_on_pick_reward_hero.bind(i))
		reward_box.add_child(btn)


func _on_pick_reward_hero(hero_index: int) -> void:
	if _pending_reward_card != "":
		GameState.add_card_reward(_pending_reward_card, hero_index)
		_on_log("Carta %s → %s" % [
			_pending_reward_card,
			str(GameState.party[hero_index].get("display_name", hero_index))
		])
	_finish_reward()


func _finish_reward() -> void:
	_pending_reward_card = ""
	reward_panel.visible = false
	combat.start_encounter(GameState.next_encounter())
	title_label.text = "Project Fallen Tactics — Campo + FOW"
	refresh_hand()
	refresh_timeline()
	refresh_party_strip()
