extends Node
class_name FWDataParser

func write_var_data(p_path: String, p_data: Variant) -> void:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.WRITE)
	file.store_var(p_data)
	file.close()

func load_var_data(p_path: String) -> Variant:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		return {}
	var data: Variant = file.get_var()
	file.close()
	
	return data

func write_loc_data(p_prefix: String, p_loc_ids: Array[StringName]) -> void:
	var path: String = "%s.csv" % p_prefix
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var header: PackedStringArray = TranslationServer.get_loaded_locales()
	header.insert(0, "id")
	file.store_csv_line(header)
	
	var locales: PackedStringArray = TranslationServer.get_loaded_locales()
	var loc_data: Dictionary = Debug.get_loc_data(p_prefix)
	for loc_id: StringName in p_loc_ids:
		var arr: PackedStringArray = PackedStringArray([loc_id])
		for locale: String in locales:
			var text: String = loc_data[loc_id][locale]
			var single_line: String = _parse_to_single_line(text)
			arr.push_back(single_line)
		file.store_csv_line(arr)
	
	file.close()

func load_loc_data(p_prefix: String) -> Dictionary:
	var path: String = "%s.csv" % p_prefix
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var locales: PackedStringArray = PackedStringArray()
	var res: Dictionary = {}
	var idx: int = 0
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line == PackedStringArray([""]):
			# Fix for empty line which is produced by 
			# FileAccess.store_csv_line -> Needs to be ignored
			continue
		
		if idx == 0:
			for i: int in range(1, line.size()):
				locales.push_back(line[i])
		else:
			var id: String = line[0]
			res[id] = {}
			for i: int in range(1, line.size()):
				var locale: String = locales[i - 1]
				res[id][locale] = line[i]
		
		idx += 1
	
	return res

func _parse_to_single_line(p_text: String) -> String:
	while p_text.find("\n") != -1:
		p_text = p_text.replace("\n", " ")
	
	return p_text

func load_ogg_stream(p_path: String) -> AudioStreamOggVorbis:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	var stream: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_buffer(buffer)
	
	return stream

func load_wav_stream(p_path: String) -> AudioStreamWAV:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	var stream: AudioStreamWAV = AudioStreamWAV.load_from_buffer(buffer)
	
	return stream

func parse_variant(p_variant: Variant) -> Dictionary:
	var data: Dictionary = {}
	if p_variant == null:
		return data
	
	var type: int = typeof(p_variant)
	var value: Variant = p_variant
	if type == TYPE_OBJECT:
		value = parse_object(value)
	data[&"Type"] = type
	data[&"Value"] = value
	
	return data

func parse_object(p_object: Object) -> Dictionary:
	var data: Dictionary = {}
	if p_object == null:
		return data
	
	data[&"Class"] = p_object.get_class()
	if p_object is RefCounted:
		data = _parse_ref_counted(p_object, data)
	else:
		push_warning("Parsing not implemented for ", p_object.get_class())
	
	return data

func _parse_ref_counted(p_object: Object, p_data: Dictionary) -> Dictionary:
	if p_object is Resource:
		p_data = _parse_resource(p_object, p_data)
	else:
		push_warning("Parsing not implemented for ", p_object.get_class())
	
	return p_data

func _parse_resource(p_resource: Resource, p_data: Dictionary) -> Dictionary:
	p_data[&"Path"] = p_resource.get_path()
	
	if p_resource is Image:
		p_data = _parse_image(p_resource, p_data)
	elif p_resource is Texture:
		p_data = _parse_texture(p_resource, p_data)
	elif p_resource is Material:
		p_data = _parse_material(p_resource, p_data)
	elif p_resource is Shape3D:
		p_data = _parse_shape_3D(p_resource, p_data)
	else:
		push_warning("Parsing not implemented for ", p_resource.get_class())
	
	return p_data

func _parse_image(p_image: Image, p_data: Dictionary) -> Dictionary:
	p_data[&"Width"] = p_image.get_width()
	p_data[&"Height"] = p_image.get_height()
	p_data[&"Mipmaps"] = p_image.has_mipmaps()
	p_data[&"Format"] = p_image.get_format()
	p_data[&"Data"] = p_image.get_data()
	
	return p_data

func _parse_texture(p_texture: Texture, p_data: Dictionary) -> Dictionary:
	if p_texture is Texture2D:
		p_data = _parse_texture_2D(p_texture, p_data)
	
	return p_data

func _parse_texture_2D(p_texture: Texture2D, p_data: Dictionary) -> Dictionary:
	if p_data[&"Path"].is_empty():
		var image: Image = p_texture.get_image()
		p_data[&"Image"] = parse_object(image)
	
	if p_texture is CompressedTexture2D:
		p_data = _parse_compressed_texture_2D(p_texture, p_data)
	elif p_texture is ImageTexture:
		pass
	else:
		push_warning("Parsing not implemented for ", p_texture.get_class())
	
	return p_data

func _parse_compressed_texture_2D(p_texture: CompressedTexture2D, p_data: Dictionary) -> Dictionary:
	p_data[&"Load_Path"] = p_texture.get_load_path()
	
	return p_data

func _parse_material(p_material: Material, p_data: Dictionary) -> Dictionary:
	var next_pass: Material = p_material.get_next_pass()
	p_data[&"Next_Pass"] = parse_object(next_pass)
	p_data[&"Render_Priority"] = p_material.get_render_priority()
	
	if p_material is ShaderMaterial:
		p_data = _parse_shader_material(p_material, p_data)
	else:
		push_warning("Parsing not implemented for ", p_material.get_class())
	
	return p_data

func _parse_shader_material(p_material: ShaderMaterial, p_data: Dictionary) -> Dictionary:
	var shader: Shader = p_material.get_shader()
	if shader == null:
		return p_data
	
	var shader_path: String = shader.get_path()
	if shader_path.is_empty():
		push_warning("Shader must be a saved resource!")
	p_data[&"Shader"] = {}
	p_data[&"Shader"][&"Path"] = shader_path
	
	p_data[&"Params"] = {}
	var uniform_list: Array = shader.get_shader_uniform_list()
	for args: Dictionary in uniform_list:
		var name_: StringName = args[&"name"]
		var value: Variant = p_material.get_shader_parameter(name_)
		p_data[&"Params"][name_] = parse_variant(value)
	
	return p_data

func _parse_shape_3D(p_shape: Shape3D, p_data: Dictionary) -> Dictionary:
	p_data[&"Custom_Solver_Bias"] = p_shape.get_custom_solver_bias()
	p_data[&"Margin"] = p_shape.get_margin()
	
	if p_shape is BoxShape3D:
		p_data = _parse_box_shape_3D(p_shape, p_data)
	elif p_shape is CapsuleShape3D:
		p_data = _parse_capsule_shape_3D(p_shape, p_data)
	else:
		push_warning("Parsing not implemented for ", p_shape.get_class())
	
	return p_data

func _parse_box_shape_3D(p_shape: BoxShape3D, p_data: Dictionary) -> Dictionary:
	p_data[&"Size"] = p_shape.get_size()
	
	return p_data

func _parse_capsule_shape_3D(p_shape: CapsuleShape3D, p_data: Dictionary) -> Dictionary:
	p_data[&"Height"] = p_shape.get_height()
	p_data[&"Radius"] = p_shape.get_radius()
	
	return p_data

func unparse_variant(p_data: Dictionary) -> Variant:
	var type: Variant.Type = p_data[&"Type"]
	if type == TYPE_OBJECT:
		return unparse_object(p_data[&"Value"])
	else:
		return p_data[&"Value"]

func unparse_object(p_data: Dictionary) -> Object:
	var object: Object = null
	if p_data.is_empty():
		return object
	
	var class_: StringName = p_data[&"Class"]
	match class_:
		&"CompressedTexture2D": object = unparse_compressed_texture_2D(p_data)
		&"ImageTexture": object = unparse_image_texture(p_data)
		&"ShaderMaterial": object = unparse_shader_material(p_data)
		&"BoxShape3D": object = unparse_box_shape_3D(p_data)
		&"CapsuleShape3D": object = unparse_capsule_shape_3D(p_data)
		_: push_error("Unparsing not implemented for ", class_)
	
	return object

func unparse_compressed_texture_2D(p_data: Dictionary) -> CompressedTexture2D:
	var texture: CompressedTexture2D = _unparse_texture(p_data)
	texture.load(p_data[&"Load_Path"])
	
	return texture

func unparse_image_texture(p_data: Dictionary) -> ImageTexture:
	var texture: ImageTexture = _unparse_texture(p_data)
	var path: String = texture.get_path()
	if path.is_empty():
		var image: Image = _unparse_image(p_data[&"Image"])
		texture.set_image(image)
	
	return texture

func unparse_shader_material(p_data: Dictionary) -> ShaderMaterial:
	var material: ShaderMaterial = _unparse_resource(p_data)
	_load_data_material(material, p_data)
	
	var shader_path: String = p_data[&"Shader"][&"Path"]
	if shader_path.is_empty():
		push_warning("Shader must be a saved resource!")
	else:
		var shader: Shader = load(shader_path)
		material.set_shader(shader)
	
	for param: StringName in p_data[&"Params"]:
		var args: Dictionary = p_data[&"Params"][param]
		var value: Variant = unparse_variant(args)
		material.set_shader_parameter(param, value)
	
	return material

func unparse_box_shape_3D(p_data: Dictionary) -> BoxShape3D:
	var shape: BoxShape3D = _unparse_resource(p_data)
	_load_data_shape_3D(shape, p_data)
	shape.set_size(p_data[&"Size"])
	
	return shape

func unparse_capsule_shape_3D(p_data: Dictionary) -> CapsuleShape3D:
	var shape: CapsuleShape3D = _unparse_resource(p_data)
	_load_data_shape_3D(shape, p_data)
	shape.set_height(p_data[&"Height"])
	shape.set_radius(p_data[&"Radius"])
	
	return shape

func _unparse_image(p_data: Dictionary) -> Image:
	var image: Image = _unparse_resource(p_data)
	var width: int  = p_data[&"Width"]
	var height: int = p_data[&"Height"]
	var mipmaps: bool = p_data[&"Mipmaps"]
	var format: int = p_data[&"Format"]
	var data: PackedByteArray = p_data[&"Data"]
	image.set_data(width, height, mipmaps, format, data)
	
	return image

func _unparse_texture(p_data: Dictionary) -> Texture:
	var texture: Texture = _unparse_resource(p_data)
	
	return texture

func _unparse_resource(p_data: Dictionary) -> Resource:
	var path: String = p_data[&"Path"]
	var resource: Resource
	if path.is_empty():
		resource = ClassDB.instantiate(p_data[&"Class"])
	else:
		resource = load(p_data[&"Path"])
	
	return resource

func _load_data_material(p_material: Material, p_data: Dictionary) -> void:
	var next_pass: Material = unparse_object(p_data[&"Next_Pass"])
	p_material.set_next_pass(next_pass)
	p_material.set_render_priority(p_data[&"Render_Priority"])

func _load_data_shape_3D(p_shape: Shape3D, p_data: Dictionary) -> void:
	p_shape.set_custom_solver_bias(p_data[&"Custom_Solver_Bias"])
	p_shape.set_margin(p_data[&"Margin"])
