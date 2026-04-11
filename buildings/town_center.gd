# 範例：town_center.gd（附加到 Town Center 場景）
extends Node2D  # 或你模板的 Structure 父類

@export var villager_scene: PackedScene

func produce_unit(unit_type: String):
	if unit_type == "villager" and villager_scene:
		var unit = villager_scene.instantiate()
		unit.global_position = global_position + Vector2(80, 80)
		get_parent().add_child(unit)
		print("Town Center 生產村民")
		# ResourceManager 扣食物等（之後整合）
