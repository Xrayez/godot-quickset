tool
extends EditorPlugin

const PLUGIN_DIR = 'plugins/quickset'
const PLUGIN_CONFIG = 'editor_settings.cfg'

const PLUGIN_EDITOR_SETTINGS_SECTION = 'editor_settings'
#const PLUGIN_PROJECT_SETTINGS_SECTION = 'project_settings' # TODO

const Entry = preload("res://addons/quickset/entry.tscn")

var dock
var dock_entries

var settings_dialog
var clear_dialog

var editor_settings = get_editor_interface().get_editor_settings()
var plugin_config = ConfigFile.new()

var settings_map = {}

var _update_queued = false


func _enter_tree():
	# Add dock
	dock = preload("dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)
	dock.get_node("buttons/add_button").connect("pressed", self, "_on_add_pressed")
	dock.get_node("buttons/clear_button").connect("pressed", self, "_on_clear_pressed")
	dock_entries = dock.get_node('panel/scroll/entries')

	# Settings dialog to pick from
	settings_dialog = dock.get_node('settings_dialog')
	settings_dialog.connect("confirmed", self, "_on_setting_confirmed")
	settings_dialog.connect('setting_selected', self, "_on_setting_selected")

	# Dialog to clear all entries
	clear_dialog = dock.get_node('clear_dialog')
	clear_dialog.connect("confirmed", self, "_on_clear_confirmed")

	# Editor settings
	editor_settings.connect('settings_changed', self, '_on_editor_settings_changed')
	_update_settings_map()
	_load_settings() # from PLUGIN_CONFIG


func _load_settings():
	var path = get_config_path()

	var fs = Directory.new()
	if not fs.file_exists(path):
		var config = ConfigFile.new()
		fs.make_dir_recursive(path.get_base_dir())
		config.save(path)
	else:
		plugin_config.load(path)

	_queue_update()


func _update_entries():

	if not plugin_config.has_section(PLUGIN_EDITOR_SETTINGS_SECTION):
		_update_queued = false
		return # empty

	_clear_entries() # existing ones

	var settings = plugin_config.get_section_keys(PLUGIN_EDITOR_SETTINGS_SECTION)

	for s in settings:
		var entry = Entry.instance()
		entry.set_setting_name(s)

		var value = editor_settings.get_setting(s)
		var hint = get_setting_hint_string(s)

		entry.set_setting_value(value, hint)
		entry.connect('changed', self, '_on_entry_changed')

		dock_entries.add_child(entry)

	_update_queued = false


func _on_editor_settings_changed():
	_update_settings_map()


func _save_settings():
	plugin_config.save(get_config_path())


func get_config_path():
	var dir = editor_settings.get_settings_dir()
	var home = dir.plus_file(PLUGIN_DIR)
	var path = home.plus_file(PLUGIN_CONFIG)

	return path


func _on_add_pressed():
	_update_settings_map()
	settings_dialog.popup_centered()


func _on_clear_pressed():
	clear_dialog.popup_centered()


func _on_clear_confirmed():
	_clear_entries()
	_clear_settings()
	_save_settings()


func _clear_settings():
	# Clear from config
	var settings = plugin_config.get_section_keys(PLUGIN_EDITOR_SETTINGS_SECTION)
	for s in settings:
		plugin_config.set_value(PLUGIN_EDITOR_SETTINGS_SECTION, s, null) # delete


func _on_setting_confirmed():
	pass


func _on_setting_selected(p_setting):

	var value = editor_settings.get_setting(p_setting)
	plugin_config.set_value(PLUGIN_EDITOR_SETTINGS_SECTION, p_setting, value)
	_save_settings()

	_queue_update()


func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()


func _queue_update():

	if not is_inside_tree():
		return

	if _update_queued:
		return

	_update_queued = true

	call_deferred("_update_entries")


func _clear_entries():
	for idx in dock_entries.get_child_count():
		var entry = dock_entries.get_child(idx)
		entry.queue_free()


func _on_entry_changed(setting, value):
	assert(editor_settings.has_setting(setting))
	editor_settings.set_setting(setting, value)


func _update_settings_map():

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


func get_setting_type(p_setting):
	assert(not settings_map.empty())

	return settings_map[p_setting].type


func get_setting_hint_string(p_setting):
	assert(not settings_map.empty())

	return settings_map[p_setting].hint_string
