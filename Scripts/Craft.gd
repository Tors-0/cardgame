extends TextureButton
var text : String

func _on_pressed() -> void:
	hide()


func _on_up_pressed() -> void:
	show()


func _on_shift_pressed() -> void:
	show()


func make_ready() -> void:
	text = $'../../../../../'.langMapDict["ui.button.craft"]
	
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = size
	var labelMaxSize := size * 0.8 # could be up to 0.85 for bad fit
	
	label.label_settings = $'../../../../../'.labelSettings
	while label.label_settings.font.get_string_size(text, label.horizontal_alignment, -1, label.label_settings.font_size).x > labelMaxSize.x:
		label.label_settings.font_size -= 1
	
	add_child(label)
