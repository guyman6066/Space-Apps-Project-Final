extends TextureProgressBar

@export var character_index: int = 0
@export_enum("health", "water", "oxygen") var stat_type: String = "health"

func _ready() -> void:
	GlobalTracker.stats_changed.connect(update_bar_animated)
	
	# Initialize values
	var char_data = GlobalTracker.characters[character_index]
	max_value = char_data["max_" + stat_type]
	value = char_data[stat_type]

func update_bar_animated() -> void:
	var current_stat_value = GlobalTracker.characters[character_index][stat_type]
	
	# Creates the fluid visual transition from current filling point to new value
	var tween = create_tween()
	tween.tween_property(self, "value", current_stat_value, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
