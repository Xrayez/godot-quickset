tool
extends VBoxContainer

signal selected()
signal changed(setting, value)

var setting_name
var setting_value


func set_setting_name(p_name):
	setting_name = p_name

	var sectionarr = p_name.split("/")

	var fullname = ""

	for sec in sectionarr:
		fullname += sec.capitalize() + " "

	$name.text = str(fullname)


func set_setting_value(p_value, p_hint = ""):

	setting_value = p_value

	if has_node('value'):
		get_node('value').queue_free()
		remove_child(get_node('value'))

	var input

	match typeof(p_value):

		TYPE_INT:
			if not p_hint.empty():
				input = OptionButton.new()

				var options = p_hint.split(',')
				for opt in options:
					input.add_item(opt)

				input.selected = p_value
				input.connect("item_selected", self, "_on_item_selected")
			else:
				input = LineEdit.new()
				input.text = str(p_value)

		TYPE_STRING:
			input = LineEdit.new()
			input.connect('text_changed', self, '_on_string_text_changed')
			input.text = str(p_value)

		TYPE_REAL:
			input = LineEdit.new()
			input.connect('text_changed', self, '_on_real_text_changed')
			input.text = str(p_value)

		TYPE_BOOL:
			input = CheckBox.new()
			input.pressed = p_value
			input.text = tr("On")
			input.connect("pressed", self, "_on_checkbox_pressed", [input])

	var err = input == null

	if not err:
		input.size_flags_horizontal = 0
		input.size_flags_vertical = 0

		add_child(input)
		input.name = 'value'
	else:
		push_warning("Quickset plugin: unsupported setting type.")

	return err


func _on_item_selected(id):
	_notify_changed(id)


func _on_checkbox_pressed(checkbox):
	_notify_changed(checkbox.pressed)


func _on_string_text_changed(text):
	_notify_changed(str(text))


func _on_real_text_changed(text):
	_notify_changed(float(text))


func _notify_changed(p_value):
	emit_signal('changed', setting_name, p_value)


class VariantEditor:

	static func create(variant, hint_string = ""):
		assert(variant != null)

		var editor = HBoxContainer.new()

#		match typeof(variant):
#			TYPE_NIL:
#				editor.add_child()
#
#			TYPE_BOOL:
#				editor.add_child()
#
#			TYPE_INT:
#				editor.add_child()
#
#			TYPE_REAL:
#				editor.add_child()
#
#			TYPE_STRING:
#				editor.add_child()
#
#			TYPE_VECTOR2:
#				editor.add_child()
#
#			TYPE_RECT2:
#				editor.add_child()
#
#			TYPE_VECTOR3:
#				editor.add_child()
#
#			TYPE_TRANSFORM2D:
#				editor.add_child()
#
#			TYPE_PLANE:
#				editor.add_child()
#
#			TYPE_QUAT:
#				editor.add_child()
#
#			TYPE_AABB:
#				editor.add_child()
#
#			TYPE_BASIS:
#				editor.add_child()
#
#			TYPE_TRANSFORM:
#				editor.add_child()
#
#			TYPE_COLOR:
#				editor.add_child()
#
#			TYPE_NODE_PATH:
#				editor.add_child()
#
#			TYPE_RID:
#				editor.add_child()
#
#			TYPE_OBJECT:
#				editor.add_child()
#
#			TYPE_DICTIONARY:
#				editor.add_child()
#
#			TYPE_ARRAY:
#				editor.add_child()
#
#			TYPE_RAW_ARRAY:
#				editor.add_child()
#
#			TYPE_INT_ARRAY:
#				editor.add_child()
#
#			TYPE_REAL_ARRAY:
#				editor.add_child()
#
#			TYPE_STRING_ARRAY:
#				editor.add_child()
#
#			TYPE_VECTOR2_ARRAY:
#				editor.add_child()
#
#			TYPE_VECTOR3_ARRAY:
#				editor.add_child()
#
#			TYPE_COLOR_ARRAY:
#				editor.add_child()

		return editor
