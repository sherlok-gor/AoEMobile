# VirtualJoystick.gd
extends Control

@export var radius := 80.0
var dragging := false
var touch_id := -1
var center := Vector2.ZERO
var selection_mode := false
var selection_center := Vector2.ZERO
var selection_radius := 0.0

@onready var selection_circle: Line2D = get_node_or_null("../../SelectionCircle")  # 放在世界層

signal camera_move(direction: Vector2)

func _ready():
	center = size / 2

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and not dragging:
			dragging = true
			touch_id = event.index
			center = event.position
			# 長按檢測
			get_tree().create_timer(0.6).timeout.connect(_check_long_press.bind(event.position))
		
		elif not event.pressed and event.index == touch_id:
			dragging = false
			if selection_mode:
				_finish_selection()
			else:
				camera_move.emit(Vector2.ZERO)
			selection_mode = false

	elif event is InputEventScreenDrag and event.index == touch_id:
		var dir = (event.position - center).limit_length(radius)
		if selection_mode:
			selection_radius = dir.length() * 4.0
			_update_circle()
		else:
			camera_move.emit(dir / radius)

func _check_long_press(pos: Vector2):
	if dragging:
		selection_mode = true
		selection_center = get_viewport().get_camera_2d().get_global_mouse_position() if get_viewport().get_camera_2d() else pos
		selection_radius = 50
		if selection_circle:
			selection_circle.visible = true
			selection_circle.position = selection_center
		print("進入圓形選擇模式")

func _update_circle():
	if not selection_circle: return
	var points := PackedVector2Array()
	for i in 48:
		var a = i * TAU / 48
		points.append(Vector2(cos(a), sin(a)) * selection_radius)
	selection_circle.points = points

func _finish_selection():
	if not selection_circle: return
	selection_circle.visible = false
	var selected_count = 0
	for unit in get_tree().get_nodes_in_group("selectable_units"):
		if unit.global_position.distance_to(selection_center) <= selection_radius + 20:
			unit.set_selected(true)
			selected_count += 1
	print("圓形選取完成：", selected_count, " 單位")
