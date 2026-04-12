# ResourceManager.gd
extends Node

signal resources_changed

const Human = preload("res://source/match/players/human/Human.gd")
const RESOURCE_RATE := 0.5  # resources per villager per second

var wood: int = 300
var food: int = 200
var gold: int = 150
var stone: int = 100

var villagers_wood: Array = []
var villagers_food: Array = []
var villagers_gold: Array = []
var villagers_stone: Array = []
var villagers_idle: Array = []

var _active_player = null
var _accumulator := 0.0


func _ready() -> void:
	MatchSignals.match_started.connect(_on_match_started)


func _process(delta: float) -> void:
	_try_sync_from_active_player()
	_accumulator += delta
	if _accumulator >= 1.0:
		_accumulator -= 1.0
		var changed := false
		if not villagers_wood.is_empty():
			wood += roundi(villagers_wood.size() * RESOURCE_RATE)
			changed = true
		if not villagers_food.is_empty():
			food += roundi(villagers_food.size() * RESOURCE_RATE)
			changed = true
		if not villagers_gold.is_empty():
			gold += roundi(villagers_gold.size() * RESOURCE_RATE)
			changed = true
		if not villagers_stone.is_empty():
			stone += roundi(villagers_stone.size() * RESOURCE_RATE)
			changed = true
		if changed:
			_sync_to_active_player()
			resources_changed.emit()


func add_villager(villager: Node, resource_type: String = "idle") -> void:
	remove_villager(villager)
	match resource_type:
		"wood":
			villagers_wood.append(villager)
		"food":
			villagers_food.append(villager)
		"gold":
			villagers_gold.append(villager)
		"stone":
			villagers_stone.append(villager)
		_:
			villagers_idle.append(villager)
	resources_changed.emit()


func remove_villager(villager: Node) -> void:
	villagers_wood.erase(villager)
	villagers_food.erase(villager)
	villagers_gold.erase(villager)
	villagers_stone.erase(villager)
	villagers_idle.erase(villager)


func has_resources(cost: Dictionary) -> bool:
	# Support both the new mobile resource naming (wood/gold)
	# and legacy match naming (resource_a/resource_b) during migration.
	return (
		wood >= (cost.get("wood", 0) + cost.get("resource_a", 0))
		and food >= cost.get("food", 0)
		and gold >= (cost.get("gold", 0) + cost.get("resource_b", 0))
		and stone >= cost.get("stone", 0)
	)


func subtract_resources(cost: Dictionary) -> void:
	wood -= cost.get("wood", 0)
	food -= cost.get("food", 0)
	gold -= cost.get("gold", 0)
	stone -= cost.get("stone", 0)
	wood -= cost.get("resource_a", 0)
	gold -= cost.get("resource_b", 0)
	_sync_to_active_player()
	resources_changed.emit()


func get_group(type: String) -> Array:
	match type:
		"wood":
			return villagers_wood
		"food":
			return villagers_food
		"gold":
			return villagers_gold
		"stone":
			return villagers_stone
		"idle":
			return villagers_idle
	return []


func _on_match_started() -> void:
	_active_player = _find_human_player()
	_try_sync_from_active_player(true)


func _find_human_player() -> Human:
	var human_players = get_tree().get_nodes_in_group("players").filter(
		func(player): return player is Human
	)
	if human_players.is_empty():
		return null
	return human_players[0]


func _try_sync_from_active_player(force_emit = false) -> void:
	if _active_player == null:
		return
	var changed = false
	if wood != _active_player.resource_a:
		wood = _active_player.resource_a
		changed = true
	if gold != _active_player.resource_b:
		gold = _active_player.resource_b
		changed = true
	if changed or force_emit:
		resources_changed.emit()


func _sync_to_active_player() -> void:
	if _active_player == null:
		return
	_active_player.resource_a = wood
	_active_player.resource_b = gold
