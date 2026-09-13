extends Control

const MOCK_PLAYER_ID := "mock:player-one"

var nft_provider := MockNFTProvider.new()
var wallet_service := MockWalletService.new()
var bet_provider := MockBetProvider.new(wallet_service)
var settlement_provider := MockSettlementProvider.new(wallet_service)
var matchmaking_service := MockMatchmakingService.new()
var commit_reveal_service := CommitRevealService.new()
var game_manager := GameManager.new()
var match_manager := MatchManager.new(bet_provider, settlement_provider, commit_reveal_service)

var selected_nft: Dictionary = {}
var selected_stake := 2
var current_match: Dictionary = {}
var last_result: Dictionary = {}

var root: VBoxContainer
var content: VBoxContainer
var balance_label: Label
var status_label: Label
var score_left_label: Label
var score_right_label: Label
var round_label: Label
var player_choice_label: Label
var opponent_choice_label: Label
var left_avatar: Control
var right_avatar: Control
var choice_buttons: Array[Button] = []
var stake_buttons := {}

func _ready() -> void:
	randomize()
	selected_nft = nft_provider.get_owned_nfts(MOCK_PLAYER_ID).front()
	matchmaking_service.opponent_found.connect(_on_opponent_found)
	match_manager.phase_changed.connect(_on_match_phase_changed)
	match_manager.round_resolved.connect(_on_round_resolved)
	match_manager.match_finished.connect(_on_match_finished)
	_build_shell()
	_show_lobby()
	if OS.get_cmdline_user_args().has("--demo"):
		call_deferred("_run_demo")

func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = UIManager.INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var ambient_top := ColorRect.new()
	ambient_top.color = Color("#0e2b58")
	ambient_top.position = Vector2(0, 0)
	ambient_top.size = Vector2(1440, 150)
	ambient_top.modulate.a = 0.35
	ambient_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ambient_top)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	var header := _build_header()
	root.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)

func _build_header() -> Control:
	var card := UIManager.make_card(Color("#0a1830e6"), Color("#286498"))
	card.custom_minimum_size = Vector2(0, 74)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	var mark := Label.new()
	mark.text = "✦"
	mark.add_theme_font_size_override("font_size", 30)
	mark.add_theme_color_override("font_color", UIManager.CYAN)
	row.add_child(mark)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := UIManager.make_label("NEON CLASH", 22, UIManager.TEXT)
	var sub := UIManager.make_label("MOCK NFT RPS PvP · CHAIN-INDEPENDENT PROTOTYPE", 11, UIManager.MUTED)
	title_box.add_child(title)
	title_box.add_child(sub)
	row.add_child(title_box)

	balance_label = UIManager.make_label("", 16, UIManager.LIME, HORIZONTAL_ALIGNMENT_RIGHT)
	balance_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(balance_label)
	_update_balance()
	return card

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()
	choice_buttons.clear()
	stake_buttons.clear()

func _show_lobby() -> void:
	game_manager.transition(GameManager.State.HOME)
	_clear_content()

	var hero := UIManager.make_card(Color("#0c1d38"), UIManager.VIOLET)
	var hero_box := VBoxContainer.new()
	hero_box.add_theme_constant_override("separation", 8)
	hero.add_child(hero_box)
	var eyebrow := UIManager.make_label("SEASON ZERO · LOCAL MOCK MATCHES", 13, UIManager.CYAN)
	var heading := UIManager.make_label("Pick an alien. Lock a virtual stake. Take the arena.", 34, UIManager.TEXT)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var copy := UIManager.make_label("No wallet, crypto, blockchain, or real money is connected in this build. The game is structured so those providers can be added later without changing its core rules.", 16, UIManager.MUTED)
	hero_box.add_child(eyebrow)
	hero_box.add_child(heading)
	hero_box.add_child(copy)
	content.add_child(hero)

	var stake_section := VBoxContainer.new()
	stake_section.add_theme_constant_override("separation", 10)
	stake_section.add_child(UIManager.make_label("1. SELECT VIRTUAL STAKE", 14, UIManager.MUTED))
	var stakes := HBoxContainer.new()
	stakes.add_theme_constant_override("separation", 10)
	for value in [1, 2, 5, 10]:
		var button := UIManager.make_button("$%d" % value, UIManager.CYAN if value == selected_stake else Color("#395779"))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "Mock credits only"
		button.pressed.connect(_select_stake.bind(value))
		stakes.add_child(button)
		stake_buttons[value] = button
	stake_section.add_child(stakes)
	content.add_child(stake_section)

	var collection_label := UIManager.make_label("2. SELECT MOCK NFT CHARACTER", 14, UIManager.MUTED)
	content.add_child(collection_label)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	for nft in nft_provider.get_owned_nfts(MOCK_PLAYER_ID):
		grid.add_child(_make_nft_selection_card(nft))
	content.add_child(grid)

	var queue_button := UIManager.make_button("FIND $%d OPPONENT" % selected_stake, UIManager.LIME)
	queue_button.custom_minimum_size = Vector2(0, 64)
	queue_button.pressed.connect(_start_matchmaking)
	content.add_child(queue_button)

	var note := UIManager.make_label("Exact-stake queue rule: $1 only matches $1, $2 only matches $2, $5 only matches $5, and $10 only matches $10.", 13, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(note)

func _make_nft_selection_card(nft: Dictionary) -> Control:
	var selected: bool = nft.get("token_id", "") == selected_nft.get("token_id", "")
	var accent := UIManager.LIME if selected else Color("#36557e")
	var card := UIManager.make_card(Color("#0d1b32"), accent)
	card.custom_minimum_size = Vector2(0, 252)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	var portrait := TextureRect.new()
	portrait.texture = load(nft.get("image", ""))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(145, 185)
	row.add_child(portrait)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 8)
	var name_label := UIManager.make_label(nft.get("name", "Unknown"), 18, UIManager.TEXT)
	var token_label := UIManager.make_label("TOKEN %s · %s" % [nft.get("token_id", "--"), nft.get("attributes", [{}])[0].get("value", "Mock")], 12, UIManager.MUTED)
	var ownership := UIManager.make_label("LOCAL MOCK OWNERSHIP", 11, UIManager.CYAN)
	var select_button := UIManager.make_button("SELECTED" if selected else "SELECT", accent)
	select_button.pressed.connect(_select_nft.bind(nft))
	details.add_child(name_label)
	details.add_child(token_label)
	details.add_child(ownership)
	details.add_spacer(true)
	details.add_child(select_button)
	row.add_child(details)
	return card

func _select_stake(value: int) -> void:
	selected_stake = value
	_show_lobby()

func _select_nft(nft: Dictionary) -> void:
	selected_nft = nft.duplicate(true)
	_show_lobby()

func _start_matchmaking() -> void:
	if not bet_provider.can_lock(MOCK_PLAYER_ID, selected_stake):
		return
	game_manager.transition(GameManager.State.MATCHMAKING)
	_clear_content()
	var card := UIManager.make_card(Color("#0c1d38"), UIManager.CYAN)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	card.add_child(box)
	var icon := UIManager.make_label("◌", 70, UIManager.CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	var title := UIManager.make_label("SEARCHING THE $%d QUEUE" % selected_stake, 27, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	var text := UIManager.make_label("The mock matchmaking service will only pair an opponent with this exact virtual stake.", 16, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	var cancel := UIManager.make_button("CANCEL SEARCH", Color("#526a88"))
	cancel.pressed.connect(_show_lobby)
	box.add_child(icon)
	box.add_child(title)
	box.add_child(text)
	box.add_child(cancel)
	content.add_child(card)

	matchmaking_service.join_queue({
		"id": MOCK_PLAYER_ID,
		"display_name": "YOU",
		"nft": selected_nft.duplicate(true),
	}, selected_stake)

func _on_opponent_found(match_data: Dictionary) -> void:
	if game_manager.state != GameManager.State.MATCHMAKING:
		return
	current_match = match_data.duplicate(true)
	if not match_manager.start_match(current_match):
		_show_lobby()
		return
	_update_balance()
	game_manager.transition(GameManager.State.MATCH_FOUND)
	_show_match_found()

func _show_match_found() -> void:
	_clear_content()
	var card := UIManager.make_card(Color("#101b3a"), UIManager.VIOLET)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	card.add_child(box)
	box.add_child(UIManager.make_label("MATCH FOUND", 14, UIManager.CYAN, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label("Your aliens are ready to clash.", 28, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER))

	var versus := HBoxContainer.new()
	versus.alignment = BoxContainer.ALIGNMENT_CENTER
	versus.add_theme_constant_override("separation", 18)
	versus.add_child(_make_compact_player(current_match.get("player_one", {}), UIManager.LIME))
	versus.add_child(UIManager.make_label("VS", 24, UIManager.VIOLET, HORIZONTAL_ALIGNMENT_CENTER))
	versus.add_child(_make_compact_player(current_match.get("player_two", {}), UIManager.PINK))
	box.add_child(versus)

	var locked := UIManager.make_label("$%d + $%d virtual credits locked · $%d prize pool" % [selected_stake, selected_stake, match_manager.prize_pool], 15, UIManager.LIME, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(locked)
	var ready := UIManager.make_button("READY · ENTER ARENA", UIManager.LIME)
	ready.custom_minimum_size = Vector2(0, 64)
	ready.pressed.connect(_start_battle)
	box.add_child(ready)
	content.add_child(card)

func _make_compact_player(player: Dictionary, accent: Color) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(190, 0)
	var portrait := TextureRect.new()
	portrait.texture = load(player.get("nft", {}).get("image", ""))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(170, 150)
	box.add_child(portrait)
	box.add_child(UIManager.make_label(player.get("display_name", "PLAYER"), 15, accent, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label(player.get("nft", {}).get("name", "Unknown NFT"), 13, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	return box

func _start_battle() -> void:
	game_manager.transition(GameManager.State.BATTLE)
	_clear_content()
	var top := _build_battle_hud()
	content.add_child(top)

	var arena := HBoxContainer.new()
	arena.alignment = BoxContainer.ALIGNMENT_CENTER
	arena.add_theme_constant_override("separation", 16)
	left_avatar = _make_arena_player(current_match.get("player_one", {}), UIManager.LIME, true)
	right_avatar = _make_arena_player(current_match.get("player_two", {}), UIManager.PINK, false)
	left_avatar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_avatar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.add_child(left_avatar)

	var portal := UIManager.make_card(Color("#111546"), UIManager.VIOLET)
	portal.custom_minimum_size = Vector2(165, 210)
	var portal_box := VBoxContainer.new()
	portal_box.alignment = BoxContainer.ALIGNMENT_CENTER
	portal.add_child(portal_box)
	portal_box.add_child(UIManager.make_label("◉", 66, UIManager.VIOLET, HORIZONTAL_ALIGNMENT_CENTER))
	portal_box.add_child(UIManager.make_label("VS", 24, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	portal_box.add_child(UIManager.make_label("BEST OF 5", 12, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	arena.add_child(portal)
	arena.add_child(right_avatar)
	content.add_child(arena)

	var state_card := UIManager.make_card(Color("#0b1a32"), UIManager.CYAN)
	status_label = UIManager.make_label("ROUND 1 · Select a move to create your private commitment", 16, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	state_card.add_child(status_label)
	content.add_child(state_card)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 14)
	for option in ["rock", "paper", "scissors"]:
		var button := UIManager.make_button(option.to_upper(), UIManager.CYAN if option != "paper" else UIManager.VIOLET)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 70)
		button.tooltip_text = "Your choice stays hidden until both commitments are locked."
		button.pressed.connect(_on_choice_pressed.bind(option))
		controls.add_child(button)
		choice_buttons.append(button)
	content.add_child(controls)

func _build_battle_hud() -> Control:
	var card := UIManager.make_card(Color("#0a1830"), Color("#315a8e"))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_child(UIManager.make_label("YOU", 12, UIManager.LIME, HORIZONTAL_ALIGNMENT_CENTER))
	score_left_label = UIManager.make_label("0", 34, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	left.add_child(score_left_label)
	row.add_child(left)

	var center := VBoxContainer.new()
	center.custom_minimum_size = Vector2(230, 0)
	round_label = UIManager.make_label("ROUND 1", 19, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	var pool := UIManager.make_label("$%d STAKE · $%d POOL" % [selected_stake, match_manager.prize_pool], 12, UIManager.CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	center.add_child(round_label)
	center.add_child(pool)
	row.add_child(center)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(UIManager.make_label("OPPONENT", 12, UIManager.PINK, HORIZONTAL_ALIGNMENT_CENTER))
	score_right_label = UIManager.make_label("0", 34, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	right.add_child(score_right_label)
	row.add_child(right)
	return card

func _make_arena_player(player: Dictionary, accent: Color, is_left: bool) -> Control:
	var card := UIManager.make_card(Color("#0d1b32"), accent)
	card.custom_minimum_size = Vector2(280, 310)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)
	box.add_child(UIManager.make_label(player.get("display_name", "PLAYER"), 15, accent, HORIZONTAL_ALIGNMENT_CENTER))
	var portrait := TextureRect.new()
	portrait.texture = load(player.get("nft", {}).get("image", ""))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(250, 190)
	if is_left:
		portrait.flip_h = false
	else:
		portrait.flip_h = false
	box.add_child(portrait)
	box.add_child(UIManager.make_label(player.get("nft", {}).get("name", "Unknown NFT"), 16, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var choice := UIManager.make_label("CHOICE: WAITING", 12, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(choice)
	if is_left:
		player_choice_label = choice
	else:
		opponent_choice_label = choice
	return card

func _on_choice_pressed(choice: String) -> void:
	for button in choice_buttons:
		button.disabled = true
	player_choice_label.text = "CHOICE: LOCKED"
	opponent_choice_label.text = "CHOICE: LOCKING"
	var result := await match_manager.play_round(choice)
	if not result.get("valid", false):
		status_label.text = result.get("reason", "Round could not be resolved")
		for button in choice_buttons:
			button.disabled = false

func _on_match_phase_changed(phase: String, detail: String) -> void:
	if status_label == null:
		return
	status_label.text = detail
	status_label.add_theme_color_override("font_color", UIManager.VIOLET if phase == "locked" else UIManager.CYAN)

func _on_round_resolved(result: Dictionary) -> void:
	var left_choice: String = result.get("player_one_choice", "").to_upper()
	var right_choice: String = result.get("player_two_choice", "").to_upper()
	player_choice_label.text = "CHOICE: %s" % left_choice
	opponent_choice_label.text = "CHOICE: %s" % right_choice
	score_left_label.text = str(result.get("player_one_score", 0))
	score_right_label.text = str(result.get("player_two_score", 0))

	var outcome: int = int(result.get("outcome", 0))
	if outcome == 1:
		status_label.text = "%s beats %s · YOU WIN THE ROUND" % [left_choice, right_choice]
		status_label.add_theme_color_override("font_color", UIManager.LIME)
		_pulse(left_avatar, UIManager.LIME)
	elif outcome == -1:
		status_label.text = "%s beats %s · OPPONENT WINS THE ROUND" % [right_choice, left_choice]
		status_label.add_theme_color_override("font_color", UIManager.DANGER)
		_pulse(right_avatar, UIManager.PINK)
	else:
		status_label.text = "BOTH REVEALED %s · DRAW · NO SCORE" % left_choice
		status_label.add_theme_color_override("font_color", UIManager.CYAN)
		_pulse(left_avatar, UIManager.CYAN)
		_pulse(right_avatar, UIManager.CYAN)

	if not result.get("match_over", false):
		round_label.text = "NEXT ROUND %d" % (match_manager.round_manager.resolved_rounds + 1)
		await get_tree().create_timer(1.4).timeout
		player_choice_label.text = "CHOICE: WAITING"
		opponent_choice_label.text = "CHOICE: WAITING"
		status_label.text = "ROUND %d · Select a move to create your private commitment" % (match_manager.round_manager.resolved_rounds + 1)
		status_label.add_theme_color_override("font_color", UIManager.TEXT)
		for button in choice_buttons:
			button.disabled = false

func _on_match_finished(result: Dictionary) -> void:
	last_result = result.duplicate(true)
	_update_balance()
	await get_tree().create_timer(1.7).timeout
	game_manager.transition(GameManager.State.RESULT)
	_show_result()

func _show_result() -> void:
	_clear_content()
	var won: bool = last_result.get("winner_id", "") == MOCK_PLAYER_ID
	var accent := UIManager.LIME if won else UIManager.PINK
	var card := UIManager.make_card(Color("#101b3a"), accent)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	box.add_child(UIManager.make_label("FINAL VICTORY" if won else "MATCH COMPLETE", 14, accent, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label("YOU WON" if won else "%s WON" % last_result.get("winner_name", "OPPONENT"), 38, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label("%d — %d" % [last_result.get("player_one_score", 0), last_result.get("player_two_score", 0)], 30, UIManager.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label("$%d VIRTUAL PRIZE POOL" % last_result.get("prize_pool", 0), 18, UIManager.LIME if won else UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIManager.make_label("Mock settlement completed. No cryptocurrency or real payment was used.", 14, UIManager.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 14)
	var rematch := UIManager.make_button("REMATCH", UIManager.LIME)
	rematch.custom_minimum_size = Vector2(220, 58)
	rematch.pressed.connect(_start_matchmaking)
	var exit := UIManager.make_button("EXIT TO LOBBY", Color("#526a88"))
	exit.custom_minimum_size = Vector2(220, 58)
	exit.pressed.connect(_show_lobby)
	actions.add_child(rematch)
	actions.add_child(exit)
	box.add_child(actions)
	content.add_child(card)

func _pulse(target: Control, _color: Color) -> void:
	if target == null:
		return
	var tween := create_tween()
	tween.tween_property(target, "scale", Vector2(1.035, 1.035), 0.14)
	tween.tween_property(target, "scale", Vector2.ONE, 0.26)

func _run_demo() -> void:
	await get_tree().process_frame
	_start_matchmaking()
	await get_tree().create_timer(1.2).timeout
	if game_manager.state != GameManager.State.MATCH_FOUND:
		push_error("Demo could not find a mock match.")
		return
	_start_battle()
	match_manager.set_demo_opponent_choices(["scissors", "rock", "scissors"])
	var demo_choices := ["rock", "paper", "rock"]
	var index := 0
	while game_manager.state == GameManager.State.BATTLE and index < demo_choices.size():
		await _on_choice_pressed(demo_choices[index])
		index += 1
		await get_tree().create_timer(2.0).timeout
	await get_tree().create_timer(2.0).timeout
	print("NEON_CLASH_DEMO_FINISHED: state=%d rounds=%d score=%d-%d" % [game_manager.state, match_manager.round_manager.resolved_rounds, match_manager.round_manager.player_one_score, match_manager.round_manager.player_two_score])

func _update_balance() -> void:
	if balance_label != null:
		balance_label.text = "◈ %d MOCK CREDITS" % wallet_service.get_balance(MOCK_PLAYER_ID)
