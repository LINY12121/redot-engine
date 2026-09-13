class_name MockBetProvider
extends BetProvider

const VALID_STAKES := [1, 2, 5, 10]

var wallet: WalletService
var _locked_stakes := {}

func _init(wallet_service: WalletService) -> void:
	wallet = wallet_service

func can_lock(player_id: String, stake: int) -> bool:
	return stake in VALID_STAKES and wallet.get_balance(player_id) >= stake

func lock_stake(match_id: String, player_id: String, stake: int) -> bool:
	if not can_lock(player_id, stake):
		return false
	if _locked_stakes.has(match_id) and _locked_stakes[match_id].has(player_id):
		return false
	if not wallet.debit(player_id, stake):
		return false
	if not _locked_stakes.has(match_id):
		_locked_stakes[match_id] = {}
	_locked_stakes[match_id][player_id] = stake
	return true

func get_prize_pool(match_id: String) -> int:
	var pool: int = 0
	for stake in _locked_stakes.get(match_id, {}).values():
		pool += int(stake)
	return pool

func release_locked_stakes(match_id: String) -> Dictionary:
	var stakes: Dictionary = _locked_stakes.get(match_id, {}).duplicate(true)
	_locked_stakes.erase(match_id)
	return stakes
