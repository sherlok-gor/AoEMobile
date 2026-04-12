# SelectionManager.gd
extends Node

signal selection_changed(selected_nodes: Array)

var current_selection: Array = []


func _ready() -> void:
	MatchSignals.unit_selected.connect(_on_match_unit_selected)
	MatchSignals.unit_deselected.connect(_on_match_unit_deselected)
	MatchSignals.unit_died.connect(_on_match_unit_died)


func _on_match_unit_selected(unit: Node) -> void:
	if unit not in current_selection:
		current_selection.append(unit)
	selection_changed.emit(current_selection)


func _on_match_unit_deselected(unit: Node) -> void:
	current_selection.erase(unit)
	selection_changed.emit(current_selection)


func _on_match_unit_died(unit: Node) -> void:
	if current_selection.erase(unit):
		selection_changed.emit(current_selection)


func select_nodes(nodes: Array) -> void:
	for node in current_selection:
		if not is_instance_valid(node):
			continue
		var selection_node = node.find_child("Selection")
		if selection_node != null and selection_node.has_method("deselect"):
			selection_node.deselect()
	current_selection = nodes
	for node in current_selection:
		if not is_instance_valid(node):
			continue
		var selection_node = node.find_child("Selection")
		if selection_node != null and selection_node.has_method("select"):
			selection_node.select()
	selection_changed.emit(current_selection)
	print("選取變化 → ", current_selection.size(), " 個物件")
