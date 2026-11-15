extends Node2D

var x = 99
var y = 64
var z = 45


func _ready():
	on_run_over()   # temporary test call, remove once it works


func on_run_over():
	$CanvasLayer/ui.show_results(x, y, z)
