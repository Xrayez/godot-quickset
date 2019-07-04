tool
extends EditorPlugin

const QUICKSET_DIR = "quickset"

const SettingField = preload("res://addons/quickset/quickset_setting.tscn")

var dock
var settings_dialog

var editor_settings = get_editor_interface().get_editor_settings()

var plugin_editor_settings = ConfigFile.new()
#var plugin_project_settings = ConfigFile.new()

var updating = false

var settings_map = {}


func _enter_tree():
	dock = preload("quickset_dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)

	dock.get_node("buttons/add_button").connect("pressed", self, "_on_add_pressed")
	settings_dialog = dock.get_node('settings_dialog')

	settings_dialog.connect("confirmed", self, "_on_setting_confirmed")
	settings_dialog.connect('setting_selected', self, "_on_setting_selected")

	editor_settings.connect('settings_changed', self, '_on_editor_settings_changed')

	_load_settings()


func _load_settings():
	var dir = editor_settings.get_settings_dir()
	var home = dir.plus_file(QUICKSET_DIR)
	var path = home.plus_file('editor_settings.cfg')

	var fs = Directory.new()
	if not fs.file_exists(path):
		var config = ConfigFile.new()
		fs.make_dir_recursive(home)
		config.save(path)
	else:
		plugin_editor_settings.load(path)
		var settings = plugin_editor_settings.get_section_keys('editor_settings')
		_populate_settings(settings)


func _populate_settings(settings : PoolStringArray):
	for s in settings:
		pass


func _on_editor_settings_changed():
#	if updating:
#		return
	_update_settings_list()


func _save_settings():
	var dir = editor_settings.get_settings_dir()
	var home = dir.plus_file(QUICKSET_DIR)
	var path = home.plus_file('editor_settings.cfg')

	plugin_editor_settings.save(path)


func _on_add_pressed():
	_update_settings_list()
	settings_dialog.popup_centered()


func _on_setting_confirmed():
	pass


func _on_setting_selected(setting):
	add_editor_setting(setting)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()


func add_editor_setting(p_setting):

	var field = SettingField.instance()
	field.set_setting_name(p_setting)

	var value = editor_settings.get_setting(p_setting)

	var hint = get_setting_hint_string(p_setting)
	field.set_setting_value(value, hint)
	field.connect('changed', self, '_on_setting_field_changed')
	plugin_editor_settings.set_value('editor_settings', p_setting, value)

	dock.get_node('panel/editor/options').add_child(field)

	_save_settings()


func _on_setting_field_changed(setting, value):
	assert(editor_settings.has_setting(setting))
	editor_settings.set_setting(setting, value)


func _update_settings_list():

	var o = editor_settings

	if not o:
		return

	var pinfo = o.get_property_list()

	var root = settings_dialog.get_node('settings')
	root.clear()
	root.create_item()

	settings_map.clear()
	var sections_map = {}

	for pi in pinfo:

		if pi.usage & PROPERTY_USAGE_CATEGORY:
			continue
		elif not (pi.usage & PROPERTY_USAGE_EDITOR):
			continue

		if (pi.name.find(":") != -1 || pi.name == "script" || pi.name == "resource_name" || pi.name == "resource_path" || pi.name == "resource_local_to_scene" || pi.name.begins_with("_global_script")):
			continue

		var sectionarr = pi.name.split("/")
		var metasection = ""
		sections_map[metasection] = root

		for i in sectionarr.size():
			var parent = sections_map[metasection]

			if i > 0:
				metasection += "/" + sectionarr[i]
			else:
				metasection = sectionarr[i]

			if not sections_map.has(metasection):
				var ms = root.create_item(parent)
				sections_map[metasection] = ms
				settings_map[metasection] = pi
				ms.set_text(0, sectionarr[i].capitalize())
				ms.set_metadata(0, metasection)
				ms.set_selectable(0, false)

				if ms.get_parent():
					ms.collapsed = true

			if i == sectionarr.size() - 1:
				# doesn't have children, make selectable
				sections_map[metasection].set_selectable(0, true)


func get_setting_hint_string(p_setting):
	assert(not settings_map.empty())

	return settings_map[p_setting].hint_string
