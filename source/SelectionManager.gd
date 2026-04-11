# SelectionManager.gd
extends Node

signal selection_changed(selected_nodes: Array)

var current_selection: Array = []

func select_nodes(nodes: Array):
	# 清空舊選取
	for node in current_selection:
		if is_instance_valid(node) and node.has_method("set_selected"):
			node.set_selected(false)
	
	current_selection = nodes
	for node in current_selection:
		if is_instance_valid(node) and node.has_method("set_selected"):
			node.set_selected(true)
	
	selection_changed.emit(current_selection)
	print("選取變化 → ", current_selection.size(), " 個物件")
