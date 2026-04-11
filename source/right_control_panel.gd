# right_control_panel.gd
extends Panel

@onready var content = $ContentContainer

func _ready():
	SelectionManager.selection_changed.connect(_on_selection_changed)

func _on_selection_changed(selected: Array):
	# 清空舊內容
	for child in content.get_children():
		child.queue_free()
	
	if selected.is_empty():
		return
	
	var first = selected[0]
	
	# === 情況1：選到建築物（Town Center、Barracks 等）===
	if first.is_in_group("structures") or first.has_method("produce_unit"):
		_show_building_production_panel(first)
	
	# === 情況2：選到村民（單位）===
	elif first.is_in_group("units") or first.is_in_group("villagers"):
		_show_villager_build_panel(selected)

func _show_building_production_panel(building: Node):
	var label = Label.new()
	label.text = "生產單位"
	content.add_child(label)
	
	# 範例：Town Center 生產村民
	var btn_villager = Button.new()
	btn_villager.text = "訓練村民 (50食物)"
	btn_villager.pressed.connect(func(): building.produce_unit("villager"))
	content.add_child(btn_villager)
	
	# 範例：Barracks 生產士兵（之後你再加其他建築）
	var btn_soldier = Button.new()
	btn_soldier.text = "訓練士兵 (60食物 20黃金)"
	btn_soldier.pressed.connect(func(): building.produce_unit("soldier"))
	content.add_child(btn_soldier)

func _show_villager_build_panel(selected_villagers: Array):
	var label = Label.new()
	label.text = "建造建築（%d 村民）" % selected_villagers.size()
	content.add_child(label)
	
	var btn_house = Button.new()
	btn_house.text = "建造房屋"
	btn_house.pressed.connect(func(): enter_build_mode("house"))
	content.add_child(btn_house)
	
	var btn_barracks = Button.new()
	btn_barracks.text = "建造兵營"
	btn_barracks.pressed.connect(func(): enter_build_mode("barracks"))
	content.add_child(btn_barracks)
	
	# 可繼續加更多建築按鈕

func enter_build_mode(building_type: String):
	print("進入建造模式 → ", building_type)
	# 之後這裡會呼叫全域 BuildManager，讓下一次點擊地圖就放置建築
	# （我下一輪再給你完整放置邏輯）
