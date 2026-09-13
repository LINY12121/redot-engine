extends SceneTree

func _init() -> void:
	_test_round_rules()
	_test_commit_reveal()
	_test_mock_stake_and_settlement()
	print("NEON_CLASH_SMOKE_TEST: PASS")
	quit()

func _test_round_rules() -> void:
	var rounds := RoundManager.new()
	var left_win := rounds.resolve("rock", "scissors")
	assert(left_win.valid and left_win.outcome == 1 and left_win.player_one_score == 1)
	var draw := rounds.resolve("paper", "paper")
	assert(draw.valid and draw.is_draw and draw.player_one_score == 1 and draw.player_two_score == 0)
	var right_win := rounds.resolve("rock", "paper")
	assert(right_win.valid and right_win.outcome == -1 and right_win.player_two_score == 1)

func _test_commit_reveal() -> void:
	var service := CommitRevealService.new()
	service.begin_round("unit-round")
	var left_secret := "left-secret"
	var right_secret := "right-secret"
	assert(service.submit_commitment("unit-round", "left", service.create_commitment("rock", left_secret)))
	assert(service.submit_commitment("unit-round", "right", service.create_commitment("scissors", right_secret)))
	assert(service.both_committed("unit-round", ["left", "right"]))
	assert(not service.submit_reveal("unit-round", "left", "paper", left_secret))
	assert(service.submit_reveal("unit-round", "left", "rock", left_secret))
	assert(service.submit_reveal("unit-round", "right", "scissors", right_secret))
	assert(service.both_revealed("unit-round", ["left", "right"]))
	assert(service.get_verified_choice("unit-round", "left") == "rock")

func _test_mock_stake_and_settlement() -> void:
	var wallet := MockWalletService.new()
	var bets := MockBetProvider.new(wallet)
	var settlement := MockSettlementProvider.new(wallet)
	assert(bets.lock_stake("unit-match", "mock:player-one", 2))
	assert(bets.lock_stake("unit-match", "mock:player-two", 2))
	assert(bets.get_prize_pool("unit-match") == 4)
	assert(wallet.get_balance("mock:player-one") == 46)
	assert(wallet.get_balance("mock:player-two") == 46)
	assert(settlement.settle("unit-match", "mock:player-one", bets.get_prize_pool("unit-match")))
	assert(wallet.get_balance("mock:player-one") == 50)
