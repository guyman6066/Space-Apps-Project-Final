extends VBoxContainer

@onready var header: Button = $Header
@onready var summary: Label = $Summary
@onready var details: RichTextLabel = $Details

func _ready() -> void:
	header.toggled.connect(_on_header_toggled)

func setup(title: String, summary_text: String, body: String) -> void:
	header.text = title
	summary.text = summary_text
	details.text = body
	details.visible = false

func _on_header_toggled(is_on: bool) -> void:
	details.visible = is_on
