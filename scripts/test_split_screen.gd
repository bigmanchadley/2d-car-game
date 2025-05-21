extends Node


@onready var players := {
	"1": {
		viewport = $"VBoxContainer/SubViewportContainer/SubViewport",
		camera = $"VBoxContainer/SubViewportContainer/SubViewport/Camera2D",
		player = $VBoxContainer/SubViewportContainer/SubViewport/Level/Player1/Car,
	},
	"2": {
		viewport = $"VBoxContainer/SubViewportContainer2/SubViewport",
		camera = $"VBoxContainer/SubViewportContainer2/SubViewport/Camera2D2",
		player = $VBoxContainer/SubViewportContainer/SubViewport/Level/Player2/Car,		
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)

