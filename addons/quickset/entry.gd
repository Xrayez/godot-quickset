tool
extends VBoxContainer

signal selected()
signal changed(setting, value)

var setting_name
var setting_value


func create(p_name, p_value, p_hint_string = ""):

	setting_name = p_name
	setting_value = p_value

	$name.text = get_setting_readable_name(setting_name)

	if has_node('value'):
		get_node('value').queue_free()
		remove_child(get_node('value'))

	var input

	match typeof(p_value):

		TYPE_BOOL:
			input = CheckBox.new()
			input.pressed = p_value
			input.text = tr("On")
			input.connect("pressed", self, "_on_checkbox_pressed", [input])

		TYPE_INT:
			if not p_hint_string.empty():
				input = OptionButton.new()

				var options = p_hint_string.split(',')
				for opt in options:
					input.add_item(opt)

				input.selected = p_value
				input.connect("item_selected", self, "_on_item_selected")
			else:
				input = LineEdit.new()
				input.text = str(p_value)

		TYPE_REAL:
			input = LineEdit.new()
			input.connect('text_changed', self, '_on_real_text_changed')
			input.text = str(p_value)

		TYPE_STRING:
			input = LineEdit.new()
			input.connect('text_changed', self, '_on_string_text_changed')
			input.text = str(p_value)

#		TYPE_VECTOR2:
#			var x = LineEdit.new()
#			var y = LineEdit.new()
#
#			x.placeholder_text = "x"
#			y.placeholder_text = "y"
#
#			input = VBoxContainer.new()
#			input.add_child(x)
#			input.add_child(y)
#
#			x.connect('text_changed', self, '_on_string_text_changed')
#			y.connect('text_changed', self, '_on_string_text_changed')

	input.size_flags_horizontal = 0
	input.size_flags_vertical = 0

	add_child(input)
	input.name = 'value'


func get_setting_readable_name(p_setting):
	var sectionarr = p_setting.split("/")

	var fullname = ""

	for i in sectionarr.size():
		var sec = sectionarr[i]
		fullname += sec.capitalize()
		if i < sectionarr.size() - 1:
			fullname += " "

	return fullname


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

		var editor = VBoxContainer.new()

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
