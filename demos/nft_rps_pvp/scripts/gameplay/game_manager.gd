class_name GameManager
extends RefCounted

signal state_changed(next_state: int)

enum State {
	HOME,
	MATCHMAKING,
	MATCH_FOUND,
	BATTLE,
	RESULT,
}

var state: State = State.HOME

func transition(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	emit_signal("state_changed", state)

func reset() -> void:
	transition(State.HOME)
