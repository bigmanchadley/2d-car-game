extends Line2D


@export var tire_path : NodePath
var transform_node
var prev
var newpos = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	if tire_path:
		transform_node = get_node(tire_path)
		self.global_position = transform_node.global_position
	else:
		push_error("Line2d: path not assigned")
	
	prev = transform_node.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cur = transform_node.global_position
	var change = cur - prev
	newpos += change
	prev = cur
	add_point(newpos)
	if get_point_count() > 500:
		remove_point(0)
