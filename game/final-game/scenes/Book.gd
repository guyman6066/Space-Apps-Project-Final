extends Control

@export var book_art: NinePatchRect
@export var pages_holder: Control
@export var left_tabs: Control
@export var right_tabs: Control
@export var page_textures: Array[Texture2D]

func _ready() -> void:
	var count := page_textures.size()
	for i in left_tabs.get_child_count():
		left_tabs.get_child(i).pressed.connect(show_page.bind(i))
	for j in right_tabs.get_child_count():
		right_tabs.get_child(j).pressed.connect(show_page.bind(count - 1 - j))
	LogbookData.complete_experiment("exp_001", "pH was 6.5")
	show_page(0)

func show_page(index: int) -> void:
	var count := page_textures.size()
	book_art.texture = page_textures[index]

	# show only the current page
	for i in pages_holder.get_child_count():
		pages_holder.get_child(i).visible = (i == index)

	# only enable tabs that exist in this sprite
	for i in left_tabs.get_child_count():
		left_tabs.get_child(i).visible = (i <= index)
	for j in right_tabs.get_child_count():
		right_tabs.get_child(j).visible = (j <= count - 2 - index)
