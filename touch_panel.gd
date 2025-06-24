extends PanelContainer

var tip_tscn = preload("res://tip.tscn")
var tip
@export_multiline var content : String
@export var texture : Texture

func _ready() -> void:
	$TextureRect.texture = texture

## 进入区域,显示tip
func _on_mouse_entered() -> void:
	# 实例化tip
	tip = tip_tscn.instantiate()
	print("parent_size=",size)
	print("parent_global_position",global_position)
	# 将父组件信息给tip处理
	tip.set_tip(content, true, global_position, size * scale)
	# 当前组件添加tip
	add_child(tip)
	# 显示tip
	tip.toggle(true)

## 离开区域,销毁tip
func _on_mouse_exited() -> void:
	if tip:
		tip.toggle(false)
