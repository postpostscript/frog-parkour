extends Node2D

@export var next_scene: PackedScene
@onready var frog := $Scale/Offset/Frog
@onready var yayyyy: AudioStreamPlayer2D = $yayyyy
@onready var scaler: Node2D = $Scale

const TILE_SIZE = 16

@onready var tilemap_layers := [
	$Scale/TileMaps/Floor,
	$Scale/TileMaps/InteractableThingys,
]

func on_size_change():
	var squares_can_fit := get_viewport().get_visible_rect().size / Vector2(18, 10) / 16
	print(squares_can_fit)
	var min_scale = min(
		squares_can_fit.x,
		squares_can_fit.y,
	)
	scaler.scale = Vector2i(min_scale, min_scale)
	
func _ready() -> void:
	on_size_change()
	get_viewport().size_changed.connect(on_size_change)

func _on_frog_moved() -> void:
	tile_under_frog()

func tile_under_frog() -> void:
	var frog_position: Vector2i = frog.position / TILE_SIZE
	
	for layer in tilemap_layers:
		var data: TileData = layer.get_cell_tile_data(frog_position)
		if data == null:
			continue
		if data.get_custom_data("die"):
			await on_die()
		elif data.get_custom_data("win"):
			await on_win()

func on_die():
	await frog.play_die()
	get_tree().reload_current_scene()
	
func on_win():
	yayyyy.play(0)
	await yayyyy.finished
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	#get_tree().current_scene.replace_by(next_scene.instantiate())
	#queue_free()
	#get_tree().root.add_child(next_scene.instantiate())
