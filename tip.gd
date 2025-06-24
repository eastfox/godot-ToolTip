extends PanelContainer

# 声明父组件上方中间位置
var parent_up_center_position : Vector2
# 声明父组件下方中间位置
var parent_down_center_position : Vector2
# 声明视图大小
var viewport_size : Vector2
# 声明初始位置
var initial_pos : Vector2 
# 声明是否触摸
var is_touch : bool = true
# 声明鼠标偏移量
const mouse_offset : Vector2 = Vector2.ONE * 5.0
# 声明透明度渐变动画
var opacity_tween : Tween = null

func _ready() -> void:
	# 获取视图范围
	viewport_size = get_viewport_rect().size
	# 默认为隐藏
	hide()



#func set_tip(_content : String, _parent_pos : Vector2 = Vector2.ZERO, _parent_size : Vector2 = Vector2.ZERO) -> void:
	## 添加文本内容	
	#%Content.append_text(_content)
	## 确认系统类型
	#var sys : String = OS.get_name()
	#print("OS=",sys)
	## 移动端列表
	#var mobile_sys_list : Array[String] = ["Android","iOS"]
	## 判断系统是否是移动端
	#if sys not in mobile_sys_list:
		#is_touch = false
		#return


## 悬浮框[br]
## _content: 悬浮框内容，可使用BBCode[br]
## _is_mobile: 是否是移动端[br]
## _parent_pos: 父组件初始位置，默认为左上角坐标，可为空[br]
## _parent_size: 父组件大小，可为空
func set_tip(_content : String, _is_mobile: bool, _parent_pos : Vector2 = Vector2.ZERO, _parent_size : Vector2 = Vector2.ZERO) -> void:
	# 添加文本内容
	%Content.append_text(_content)
	# 确认操作端，非移动端就不调整位置
	if !_is_mobile:
		is_touch = _is_mobile
		return

	# 设置左右偏移量
	var h_offset = Vector2(_parent_size.x * -0.5, 0) + Vector2(_parent_size.x, 0)
	# 父组件上中位置
	parent_up_center_position = _parent_pos + h_offset
	print("parent_up_center_position=",parent_up_center_position)
	# 设置纵向偏移量
	var v_offset = Vector2(0, _parent_size.y)
	# 父组件下中位置
	parent_down_center_position = parent_up_center_position + v_offset
	print("parent_down_center_position=",parent_down_center_position)

##　当大小变化时，调整位置
func _on_resized() -> void:
	if is_touch:
		print("tip_size=",size)
		# 默认使用父节点上中位置
		initial_pos = parent_up_center_position - Vector2(size.x/2, size.y)
		
		# 检查如果初始高度高于窗口,使用父节点下中位置
		if initial_pos.y < 0:
			initial_pos = parent_down_center_position - Vector2(size.x/2, 0)
		
		# 检查并调整水平位置
		# 如果超出右边界，向左移动超出的部分
		if initial_pos.x + size.x > viewport_size.x:
			initial_pos.x = viewport_size.x - size.x
		# 如果超出左边界，移动到左边界
		elif initial_pos.x < 0:
			initial_pos.x = 0
		
		global_position = initial_pos
		print("tip_position=",global_position)
		
	elif !is_touch:
		print("tip_size=",size)
		# 检查如果超过下底边，则在鼠标上方显示
		if get_global_mouse_position().y + size.y > viewport_size.y:
			initial_pos.y = get_global_mouse_position().y - size.y - mouse_offset.y
		else:
			initial_pos.y += mouse_offset.y
		
		# 检查并调整水平位置
		# 如果超出右边界，则在鼠标左侧显示
		if get_global_mouse_position().x + size.x > viewport_size.x:
			initial_pos.x = get_global_mouse_position().x - size.x
		else:
			initial_pos.x += mouse_offset.x
		
		global_position = initial_pos
		print("tip_position=",global_position)

## 获取鼠标位置
func _input(event: InputEvent) -> void:
	if visible and !is_touch and event is InputEventMouseMotion:
		initial_pos = get_global_mouse_position()
		print("mouse_position=",initial_pos)
	_on_resized()

## 悬浮开关
func toggle(_on : bool) -> void:
	if _on:
		# 设置透明度Alpha分量初始值为0，完全透明
		modulate.a = 0.0
		show()
		# 调用透明度渐变方法
		tween_opacity(1.0)
	else:
		# 设置透明度Alpha分量初始值为1，完全不透明
		modulate.a = 1.0
		# 等待透明度渐变完成
		await tween_opacity(0.0).finished
		# 销毁tip
		queue_free()

## 透明度渐变方法[br]
## _to: 目标透明度[br]
## _duration: 持续时间，默认为0.3
func tween_opacity(_to : float, _duration : float = 0.3) -> Tween:
	# 如果正在播放动画，如鼠标持续移动，则先停止
	if opacity_tween :
		opacity_tween.kill()
	# 创建动画
	opacity_tween = get_tree().create_tween()
	# 设置动画不受暂停影响
	opacity_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# 设置动画属性，modulate:a是透明度属性
	opacity_tween.tween_property(self, 'modulate:a', _to, _duration)
	return opacity_tween
