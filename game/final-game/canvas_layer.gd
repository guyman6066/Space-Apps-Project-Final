extends CanvasLayer

# ============================================
#  1) YOUR QUESTIONS - edit these 3 lists
#  Question 1 uses the first item in every list,
#  question 2 uses the second item, and so on.
#  Add more questions by adding to ALL THREE lists.
# ============================================

# The picture shown for each question
# (tip: right-click a file in Godot's FileSystem panel -> "Copy Path")
var images = [
	"res://Free/Background/Blue.png",
	"res://Free/Background/Green.png",
	"res://Free/Background/Pink.png",
	"res://Free/Background/Gray.png",
	"res://Free/Background/Purple.png",
]

# The 4 answer choices for each question
var answers = [
	["Blue", "Green", "Pink", "Yellow"],
	["Gray", "Purple", "Green", "Brown"],
	["Pink", "Blue", "Yellow", "Gray"],
	["Brown", "Gray", "Green", "Pink"],
	["Yellow", "Blue", "Purple", "Brown"],
]

# Which choice is correct for each question.
# 0 = first button, 1 = second, 2 = third, 3 = fourth
var correct_answers = [0, 2, 0, 1, 2]


# ============================================
#  2) VARIABLES THAT KEEP TRACK OF THE QUIZ
# ============================================
var question_number = 0       # which question we're on (0 = the first)
var score = 0                 # how many answers were right
var percent_correct = 0.0     # final result, 0 to 100. This is your saved variable!


# ============================================
#  3) CONNECT TO THE NODES YOU MADE
#  The names after the $ must match your node names exactly.
# ============================================
@onready var calibrate_button = $CalibrateButton
@onready var quiz_panel = $QuizPanel
@onready var quiz_image = $QuizPanel/QuizImage
@onready var option1 = $QuizPanel/Option1
@onready var option2 = $QuizPanel/Option2
@onready var option3 = $QuizPanel/Option3
@onready var option4 = $QuizPanel/Option4
@onready var result_label = $ResultLabel


# ============================================
#  4) CODE THAT RUNS
# ============================================

# _ready runs once, when the game starts.
func _ready():
	calibrate_button.visible = Rover.rover
	Rover.rover_built.connect(is_rover_built)
	Rover.rover_destroyed.connect(is_rover_destroyed)
	quiz_panel.hide()      # hide the quiz until the button is pressed
	result_label.hide()    # hide the result until the end

	# "When this button is pressed, run this function"
	calibrate_button.pressed.connect(on_calibrate_pressed)
	option1.pressed.connect(func(): answer_chosen(0))
	option2.pressed.connect(func(): answer_chosen(1))
	option3.pressed.connect(func(): answer_chosen(2))
	option4.pressed.connect(func(): answer_chosen(3))
	
func is_rover_built():
	calibrate_button.visible = true
	
func is_rover_destroyed():
	calibrate_button.visible = false

# Runs when the Calibrate button is clicked.
func on_calibrate_pressed():
	question_number = 0
	score = 0
	calibrate_button.disabled = true   # stops the player clicking it again
	quiz_panel.show()
	show_question()


# Puts the current question's picture and answers on screen.
func show_question():
	quiz_image.texture = load(images[question_number])
	option1.text = answers[question_number][0]
	option2.text = answers[question_number][1]
	option3.text = answers[question_number][2]
	option4.text = answers[question_number][3]


# Runs whenever the player clicks an answer.
# "choice" is which button they clicked (0, 1, 2 or 3).
func answer_chosen(choice):
	if choice == correct_answers[question_number]:
		score += 1                      # right answer: add 1 to the score

	question_number += 1                # move to the next question

	if question_number < images.size():
		show_question()                 # more questions left
	else:
		finish_quiz()                   # that was the last one


# Runs after the last question.
func finish_quiz():
	percent_correct = float(score) / images.size() * 100
	print("Percent correct: ", percent_correct)   # shows in the Output panel

	quiz_panel.hide()
	calibrate_button.hide()             # the Calibrate button disappears
	result_label.text = "Calibration accuracy: " + str(round(percent_correct)) + "%"
	result_label.show()
