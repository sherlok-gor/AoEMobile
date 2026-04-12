# right_control_panel.gd
extends Panel

const WorkerScene = preload("res://source/match/units/Worker.tscn")
const WorkerScript = preload("res://source/match/units/Worker.gd")
const CommandCenterScene = preload("res://source/match/units/CommandCenter.tscn")
const VehicleFactoryScene = preload("res://source/match/units/VehicleFactory.tscn")

@onready var content = $ContentContainer


func _ready():
	hide()
	SelectionManager.selection_changed.connect(_on_selection_changed)


func _on_selection_changed(selected: Array):
	for child in content.get_children():
		child.queue_free()

	if selected.is_empty():
		hide()
		return

	show()

	var first = selected[0]

	# === 情況1：選到建築物（有生產隊列的單位）===
	if first.find_child("ProductionQueue") != null:
		_show_building_production_panel(first)

	# === 情況2：選到工作單位（Worker）===
	elif _is_worker(first) and first.is_in_group("controlled_units"):
		_show_villager_build_panel(selected)


func _show_building_production_panel(building: Node):
	var label = Label.new()
	label.text = "生產單位"
	content.add_child(label)

	var production_queue = building.find_child("ProductionQueue")
	if production_queue == null:
		return

	var btn_worker = Button.new()
	btn_worker.text = "訓練工人"
	btn_worker.pressed.connect(func(): production_queue.produce(WorkerScene))
	content.add_child(btn_worker)


func _show_villager_build_panel(selected_units: Array):
	var label = Label.new()
	label.text = "建造建築（%d 單位）" % selected_units.size()
	content.add_child(label)

	var btn_cc = Button.new()
	btn_cc.text = "建造指揮中心"
	btn_cc.pressed.connect(func(): _enter_build_mode(CommandCenterScene))
	content.add_child(btn_cc)

	var btn_factory = Button.new()
	btn_factory.text = "建造載具工廠"
	btn_factory.pressed.connect(func(): _enter_build_mode(VehicleFactoryScene))
	content.add_child(btn_factory)


func _enter_build_mode(unit_scene) -> void:
	MatchSignals.place_structure.emit(unit_scene)
	print("進入建造模式 → ", unit_scene.resource_path)


func _is_worker(unit: Node) -> bool:
	return unit is WorkerScript
