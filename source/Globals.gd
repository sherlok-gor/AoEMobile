extends Node

# === 新增：世紀帝國風格資源系統 ===
var wood: int = 300
var food: int = 200
var gold: int = 150
var stone: int = 100

var villagers_wood: Array = []
var villagers_food: Array = []
var villagers_gold: Array = []
var villagers_stone: Array = []
var villagers_idle: Array = []

signal resources_changed

func add_villager(villager: Node, resource_type: String = "idle"):
	match resource_type:
		"wood": villagers_wood.append(villager)
		"food": villagers_food.append(villager)
		"gold": villagers_gold.append(villager)
		"stone": villagers_stone.append(villager)
		_: villagers_idle.append(villager)
	resources_changed.emit()

func get_group(type: String) -> Array:
	match type:
		"wood": return villagers_wood
		"food": return villagers_food
		"gold": villagers_gold
		"stone": villagers_stone
		"idle": return villagers_idle
	return []

func update_resources():
	resources_changed.emit()

# ==================== 以下為原本的 Globals.gd 內容 ====================

const Options = preload("res://source/data-model/Options.gd")
var options = (
	load(Constants.OPTIONS_FILE_PATH)
	if ResourceLoader.exists(Constants.OPTIONS_FILE_PATH)
	else Options.new()
)
var god_mode = false
var cache = {}

func _unhandled_input(event):
	if event.is_action_pressed("toggle_god_mode"):
		_toggle_god_mode()

func _toggle_god_mode():
	if not FeatureFlags.god_mode:
		return
	god_mode = not god_mode
	if god_mode:
		Signals.god_mode_enabled.emit()
	else:
		Signals.god_mode_disabled.emit()
