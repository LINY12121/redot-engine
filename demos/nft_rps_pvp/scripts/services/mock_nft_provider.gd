class_name MockNFTProvider
extends NFTProvider

const DATA_PATH := "res://data/mock_nfts.json"

var _nfts: Array = []

func _init() -> void:
	_load_metadata()

func _load_metadata() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Mock NFT metadata could not be opened: %s" % DATA_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Mock NFT metadata must be a JSON array.")
		return
	_nfts = parsed

func get_owned_nfts(owner_id: String) -> Array:
	var owned: Array = []
	for nft in _nfts:
		if nft.get("owner", "") == owner_id:
			owned.append(nft.duplicate(true))
	return owned

func get_all_nfts() -> Array:
	var copies: Array = []
	for nft in _nfts:
		copies.append(nft.duplicate(true))
	return copies

func get_nft_by_token_id(token_id: String) -> Dictionary:
	for nft in _nfts:
		if nft.get("token_id", "") == token_id:
			return nft.duplicate(true)
	return {}
