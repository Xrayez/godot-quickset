tool
extends VBoxContainer

signal changed(setting, value)

var setting_name


func set_setting_name(p_name):
	setting_name = p_name

	var sectionarr = p_name.split("/")

	var fullname = ""

	for sec in sectionarr:
		fullname += sec.capitalize() + " "

	$name.text = str(fullname)


func set_setting_value(p_value, p_hint = ""):

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

	input.size_flags_horizontal = 0
	input.size_flags_vertical = 0

	add_child(input)
	input.name = 'value'


func _on_item_selected(id):
	_notify_changed(id)


func _notify_changed(p_value):
	emit_signal('changed', setting_name, p_value)
