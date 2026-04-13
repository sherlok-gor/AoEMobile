# SelectionManager.gd
extends Node

signal selection_changed(selected_nodes: Array)

var current_selection: Array = []


func _ready() -> void:
	if not FeatureFlags.prefer_new_mobile_ui:
		return
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

