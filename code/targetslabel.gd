extends Label

var targets_left = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.target_destroyed.connect(_on_target_destroyed)
	Global.start_game.connect(_on_start)

func _on_start():
	targets_left = 10
	text = "targets_left: " + str(targets_left)

func _on_target_destroyed():
	targets_left -= 1
	if targets_left == 0:
		Global.game_over.emit()
	text = "Targets left: " + str(targets_left)
