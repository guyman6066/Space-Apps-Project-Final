extends ScrollContainer

@onready var text: RichTextLabel = $Text

func _ready() -> void:
	text.text = FileAccess.get_file_as_string(LogbookData.GUIDE_PATH)
