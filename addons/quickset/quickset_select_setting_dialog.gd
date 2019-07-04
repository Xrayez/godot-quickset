tool
extends ConfirmationDialog

signal setting_selected(setting, hint)

var selected


func _on_settings_item_activated():
	selected = $settings.get_selected()
	emit_signal('setting_selected', selected.get_metadata(0), selected.get_meta('hint'))
	hide()
