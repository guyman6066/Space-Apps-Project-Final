extends Control

@onready var scorecount = $Run_Over/PanelContainer/MarginContainer/VBoxContainer/ScoreCount

var lettergrade : String
var grade : float


func _ready():
	%Run_Over.hide()


func show_results(x, y, z):
	print("show_results called")
	grade = (x + y + z) / 3.0
	lettergrade = get_letter_grade(grade)
	print("grade: ", grade, " letter: ", lettergrade)
	scorecount.text = lettergrade
	%Run_Over.show()
	print("Run_Over visible: ", %Run_Over.visible, " size: ", %Run_Over.size)

func get_letter_grade(score: float) -> String:
	if score >= 80:
		return "A*"
	elif score >= 70:
		return "A"
	elif score >= 60:
		return "B"
	elif score >= 40:
		return "C"
	else:
		return "Fail"
