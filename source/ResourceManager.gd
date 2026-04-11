# ResourceManager.gd
extends Node

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
		"gold": return villagers_gold
		"stone": return villagers_stone
		"idle": return villagers_idle
	return []
