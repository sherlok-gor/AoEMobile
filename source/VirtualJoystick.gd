# VirtualJoystick.gd
extends Control

signal camera_move(direction: Vector2)

const LONG_PRESS_DURATION := 0.6
const INITIAL_SELECTION_RADIUS := 50.0
const DEFAULT_WORLD_RADIUS := 5.0
const RIGHT_PANEL_BOUNDARY_RATIO := 0.8

@export var radius := 80.0
@export var selection_circle: Line2D = null

var dragging := false
var touch_id := -1
var center := Vector2.ZERO
var selection_mode := false
var selection_center := Vector2.ZERO
var selection_radius := 0.0


func _ready() -> void:
	center = size / 2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not dragging:
			if event.position.x > get_viewport_rect().size.x * RIGHT_PANEL_BOUNDARY_RATIO:
				return
			dragging = true
			touch_id = event.index
			center = event.position
			get_tree().create_timer(LONG_PRESS_DURATION).timeout.connect(
				_check_long_press.bind(event.position)
			)

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


func _check_long_press(pos: Vector2) -> void:
	if dragging:
		selection_mode = true
		selection_center = pos
		selection_radius = INITIAL_SELECTION_RADIUS
		if selection_circle:
			selection_circle.visible = true
			selection_circle.position = selection_center
		print("進入圓形選擇模式")


func _update_circle() -> void:
	if not selection_circle:
		return
	var points := PackedVector2Array()
	for i in 48:
		var a = i * TAU / 48
		points.append(Vector2(cos(a), sin(a)) * selection_radius)
	selection_circle.points = points
	selection_circle.position = selection_center


func _finish_selection() -> void:
	if selection_circle:
		selection_circle.visible = false

	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var ground_plane := Plane(Vector3.UP, 0)
	var center_3d: Variant = ground_plane.intersects_ray(
		camera.project_ray_origin(selection_center), camera.project_ray_normal(selection_center)
	)
	if center_3d == null:
		return

	# Convert screen-space radius to world-space radius
	var edge_screen := selection_center + Vector2(selection_radius, 0)
	var edge_3d: Variant = ground_plane.intersects_ray(
		camera.project_ray_origin(edge_screen), camera.project_ray_normal(edge_screen)
	)
	var world_radius := DEFAULT_WORLD_RADIUS
	if edge_3d != null:
		world_radius = (center_3d as Vector3).distance_to(edge_3d as Vector3)

	# Deselect all first, then select units within radius
	MatchSignals.deselect_all_units.emit()
	var selected_count := 0
	for unit in get_tree().get_nodes_in_group("controlled_units"):
		var unit_pos_flat := Vector3(unit.global_position.x, 0.0, unit.global_position.z)
		if unit_pos_flat.distance_to(center_3d as Vector3) <= world_radius:
			var selection_node = unit.find_child("Selection")
			if selection_node != null and selection_node.has_method("select"):
				selection_node.select()
				selected_count += 1
	print("圓形選取完成：", selected_count, " 單位")
