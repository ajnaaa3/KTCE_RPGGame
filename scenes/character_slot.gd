extends Control
class_name CharacterSlot

signal slot_pressed(slot)

var character
var is_selected := false

@onready var name_label: Label = $VBoxContainer/Label
@onready var icon_rect: TextureRect = $VBoxContainer/PanelContainer/TextureRect
@onready var panel_container: PanelContainer = $VBoxContainer/PanelContainer


func set_character(c) -> void:
	character = c
	name_label.text = c.name
	icon_rect.texture = c.texture


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	mouse_entered.connect(func():
		scale = Vector2(1.03, 1.03)
	)

	mouse_exited.connect(func():
		scale = Vector2.ONE
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		slot_pressed.emit(self)


func set_selected(selected: bool) -> void:
	is_selected = selected

	if selected:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.set_border_width_all(3)
		style.border_color = Color(0.4, 0.9, 0.4)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6

		panel_container.add_theme_stylebox_override("panel", style)
	else:
		panel_container.remove_theme_stylebox_override("panel")
