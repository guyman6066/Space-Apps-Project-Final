extends Node

const SCENE_LABELS := {
	"res://stuff_ahlam_made/demoplayscreen.tscn": ["Label"],               # one label
	"res://stuff_ahlam_made/bedroom.tscn": ["Label"],               # one label
	"res://stuff_ahlam_made/depresurizationchamber.tscn": ["Label", "Label2"],   # two labels
	"res://stuff_ahlam_made/livingroom.tscn": ["Label", "Label2"],
	"res://stuff_ahlam_made/healthlab.tscn": ["Label", "Label2"],
	"res://stuff_ahlam_made/mobilitywing.tscn": ["Label", "Label2"]
	}
	
const ASTRONAUT_FOR_BED := {
	1: "newastronaut3",  # Sleep
	2: "newastronaut",   # Sleep3
	3: "newastronaut2",  # Sleep2
	4: "newastronaut4",  # Sleep4
}
	
var party: Array = []
var sleep_end_times := {}   # bed_id -> unix time when they wak

func game_now() -> float:
	return (TimeManager.total_days - 1) * 86400.0 + TimeManager.current_time

func start_sleep(bed_id: int, duration: float) -> void:
	sleep_end_times[bed_id] = game_now() + duration
	_set_astronaut_sleeping(bed_id, true)
	
func clear_sleep(bed_id: int) -> void:
	sleep_end_times.erase(bed_id)
	_set_astronaut_sleeping(bed_id, false)
	
func get_remaining(bed_id: int) -> float:
	if not sleep_end_times.has(bed_id):
		return 0.0
	return max(0.0, sleep_end_times[bed_id] - game_now())
	
func _set_astronaut_sleeping(bed_id: int, sleeping: bool) -> void:
	for p in party:
		if is_instance_valid(p) and p.name == ASTRONAUT_FOR_BED[bed_id]:
			p.set_meta("sleeping", sleeping)
			p.visible = not sleeping
			p.process_mode = Node.PROCESS_MODE_DISABLED if sleeping else Node.PROCESS_MODE_INHERIT
			
func _process(_delta: float) -> void:
	# Wakes characters even while you're in another room
	for bed_id in sleep_end_times.keys():
		if get_remaining(bed_id) <= 0.0:
			clear_sleep(bed_id)
	
#func change_scene_with_players(target_path: String, 
#player: Node2D, player2: Node2D, player3: Node2D, player4: Node2D) -> void:
	# 1. Take the player out of the current scene tree so it doesn't get deleted
	#if player.get_parent():
		#player.get_parent().remove_child(player)
	#if player2.get_parent():
		#player2.get_parent().remove_child(player2)
	#if player3.get_parent():
		#player3.get_parent().remove_child(player3)
	#if player4.get_parent():
		#player4.get_parent().remove_child(player4)
	
	# 2. Change to the new scene
	#get_tree().change_scene_to_file(target_path)
	
func change_scene_with_players(target_path: String, 
players: Array[Node2D], spawn_positions: Array[Vector2]) -> void:
	party = players
	for p in players:
		if p.get_parent():
			p.get_parent().remove_child(p)
	
	# 3. Wait one frame for the new scene to load, then add the player into it
	get_tree().change_scene_to_file(target_path)
	await get_tree().process_frame
	while get_tree().current_scene == null:
		await get_tree().process_frame
		
	var scene := get_tree().current_scene
	
	var insert_index := -1
	if SCENE_LABELS.has(target_path):
		for label_name in SCENE_LABELS[target_path]:
			var label := scene.get_node_or_null(label_name)
			if label != null:
				insert_index = max(insert_index, label.get_index())
	else:
		push_warning("No labels listed for %s" % target_path)
		
	for i in players.size():
		scene.add_child(players[i])
		if insert_index >= 0:
			scene.move_child(players[i], insert_index + 1 + i)
		players[i].global_position = spawn_positions[i]
		if not players[i].get_meta("sleeping", false):
			players[i].show()
			players[i].process_mode = Node.PROCESS_MODE_INHERIT
		
	#get_tree().current_scene.add_child(player)
	#get_tree().current_scene.add_child(player2)
	#get_tree().current_scene.add_child(player3)
	#get_tree().current_scene.add_child(player4)
	
	# 4. Optional: Set where the player spawns in the new scene
	#player.global_position = Vector2(564, 254)
	#player2.global_position = Vector2(563, 394)
	#player3.global_position = Vector2(654, 254)
	#player4.global_position = Vector2(650, 396)
