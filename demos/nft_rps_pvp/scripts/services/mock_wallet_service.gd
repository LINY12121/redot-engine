class_name MockWalletService
extends WalletService

var _balances := {
	"mock:player-one": 48,
	"mock:player-two": 48,
}

func get_balance(player_id: String) -> int:
	return int(_balances.get(player_id, 0))

func credit(player_id: String, amount: int) -> void:
	_balances[player_id] = get_balance(player_id) + max(amount, 0)

func debit(player_id: String, amount: int) -> bool:
	if amount <= 0 or get_balance(player_id) < amount:
		return false
	_balances[player_id] = get_balance(player_id) - amount
	return true

func reset() -> void:
	_balances["mock:player-one"] = 48
	_balances["mock:player-two"] = 48
