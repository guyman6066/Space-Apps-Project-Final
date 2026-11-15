extends VBoxContainer

enum WeatherState {
	NORMAL,
	SNOWY,
	SANDSTORM
}

@export var change_interval: float = 5.0
var time_left: float = 0.0
var current_weather: WeatherState = WeatherState.NORMAL

@onready var weather_display = $weatherDisplay
@onready var chemical_display = $chemicalDisplay

var chemical_table: Dictionary = {
	WeatherState.NORMAL: "Argon / Iron Oxide",
	WeatherState.SNOWY: "Water Ice / Nitrogen",
	WeatherState.SANDSTORM: "Sulfate / Silicon Dioxide"
}

func _ready() -> void:
	time_left = change_interval
	update_displays()

func _process(delta: float) -> void:
	time_left -= delta
	
	if time_left <= 0:
		time_left = change_interval
		current_weather = randi_range(0, 2)
		update_displays()
	
func update_displays() -> void:
	match current_weather:
		WeatherState.NORMAL:
			weather_display.text = "Weather: Normal"
		WeatherState.SNOWY:
			weather_display.text = "Weather: Snowstorm"
		WeatherState.SANDSTORM:
			weather_display.text = "Weather: Sandstorm"
	var current_chemical = chemical_table[current_weather]
	chemical_display.text = "Chemicals: " + current_chemical


		
