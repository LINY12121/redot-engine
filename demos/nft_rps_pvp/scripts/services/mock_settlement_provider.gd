class_name MockSettlementProvider
extends SettlementProvider

var wallet: WalletService
var settlements: Array = []

func _init(wallet_service: WalletService) -> void:
	wallet = wallet_service

func settle(match_id: String, winner_id: String, prize_pool: int) -> bool:
	if prize_pool <= 0:
		return false
	wallet.credit(winner_id, prize_pool)
	settlements.append({
		"match_id": match_id,
		"winner_id": winner_id,
		"prize_pool": prize_pool,
	})
	return true
