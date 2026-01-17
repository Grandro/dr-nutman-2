extends Node

signal data_loaded()

@export var _e_data: Dictionary = {}

func _ready() -> void:
	_init_data()

func _init_data() -> void:
#	var config: ConfigFile = ConfigFile.new()
#	var err: Error = config.load("res://DEBUG_DATA.cfg")
#	var data: Dictionary = config.get_value("Data", "Data")
#	var debug_data: Dictionary = data["Debug"]["Data"]
#	Data_Parser.write_var_data("res://Data/Debug.dat", debug_data)
	
	var path: String = _e_data[&"Debug"][&"Path"]
	_e_data[&"Debug"][&"Data"] = Data_Parser.load_var_data(path)
	
	#_fix_entry_lists_data()
	#_fix_cutscenes_data()
	#_fix_stater_data()
	
	#var cutscenes_data: Dictionary = _e_data["Debug"]["Data"]["Cutscenes"]
	#var map_data: Dictionary = cutscenes_data["Map"]
	#for chapter: String in map_data:
		#for location: String in map_data[chapter]:
			#for key: String in map_data[chapter][location]:
				#var cutscene_data: Array[Dictionary] = map_data[chapter][location][key]["Data"]
				#for commands_args: Dictionary in cutscene_data:
					#var commands_data: Array[Dictionary] = commands_args["Data"]["Default"]
					#for command_args: Dictionary in commands_data:
						#var command: String = command_args["Command"]
						#if command == "Match":
							#var command_data: Dictionary = command_args["Data"]
							#
							#command_data["Menus"] = {}
							#command_data["Menus"]["Choices"] = {}
							#command_data["Menus"]["Choices"]["Branches_Values"] = []
							#command_data["Menus"]["Script"] = {}
							#command_data["Menus"]["Script"]["Expression"] = command_data["Args"]
							#command_data["Menus"]["Script"]["Branches_Values"] = command_data["Branch_Values"]
							#
							#command_data.erase("Args")
							#command_data.erase("Branch_Values")
							#pass
						
						#var command_data: Dictionary = command_args["Data"]
						#if command_data.has("Object"):
							#var object_data: Dictionary = command_data["Object"]
							#if !object_data.has("Properties"):
								#object_data["Properties"] = {}
							#if !object_data.has("Equipables"):
								#object_data["Equipables"] = {}
	
	#var chapter_1_data: Dictionary = _e_data["Debug"]["Data"]["Cutscenes"]["Map"]["Chapter_1"]
	#for location: String in chapter_1_data:
		#for key: String in chapter_1_data[location]:
			#var cutscene_data: Array[Dictionary] = chapter_1_data[location][key]["Data"]
			#for commands_args: Dictionary in cutscene_data:
				#var commands_data: Array[Dictionary] = commands_args["Data"]
				#commands_args["Data"] = {}
				#commands_args["Data"]["Default"] = commands_data
				#for command_args: Dictionary in commands_data:
					#_fix_cutscene_command(command_args)
	
	#var stater_data: Dictionary = _e_data["Debug"]["Data"]["Stater"]
	#var chapter_1_data: Dictionary = stater_data["Map"]["Chapter_1"]
	#for location: String in chapter_1_data:
		#for object_key: String in chapter_1_data[location]:
			#var data: Dictionary = chapter_1_data[location][object_key]
			#for args: Dictionary in data["Data"]:
				#for actions_data: Array[Dictionary] in args["Data"]["Actions"]:
					#for actions_args: Dictionary in actions_data:
						#_fix_cutscene_command(actions_args)
	
	#var chapter_1_data: Dictionary = _e_data["Debug"]["Data"]["Cutscenes"]["Map"]["Chapter_1"]
	#for location: String in chapter_1_data:
		#for key: String in chapter_1_data[location]:
			#var cutscene_data: Array[Dictionary] = chapter_1_data[location][key]["Data"]
			#for commands_args: Dictionary in cutscene_data:
				#var commands_data: Array[Dictionary] = commands_args["Data"]
				#for command_args: Dictionary in commands_data:
					#_fix_cutscene_command(command_args)
	
	data_loaded.emit()

func _fix_cutscenes_data() -> void:
	var cutscenes_data: Dictionary = _e_data[&"Debug"][&"Data"][&"Cutscenes"]
	var map_data: Dictionary = cutscenes_data[&"Map"]
	for chapter: StringName in map_data:
		for location: StringName in map_data[chapter]:
			for key: StringName in map_data[chapter][location]:
				var cutscene_data: Dictionary = map_data[chapter][location][key][&"Data"]
				for commands_args: Dictionary in cutscene_data.values():
					var commands_data: Array[Dictionary] = commands_args[&"Data"][&"Default"]
					for command_args: Dictionary in commands_data:
						_fix_cutscene_command(command_args)
	
	var global_data: Dictionary = cutscenes_data[&"Global"]
	for key: StringName in global_data:
		var cutscene_data: Dictionary = global_data[key][&"Data"]
		for commands_args: Dictionary in cutscene_data.values():
			var commands_data: Array[Dictionary] = commands_args[&"Data"][&"Default"]
			for command_args: Dictionary in commands_data:
				_fix_cutscene_command(command_args)

func _fix_cutscene_command(p_args: Dictionary) -> void:
	var _command: StringName = p_args[&"Command"]
	var _command_data: Dictionary = p_args[&"Data"]
	
	if p_args[&"Args"].has(&"Branches"):
		var branches: Dictionary = p_args[&"Args"][&"Branches"]
		for branch_args: Dictionary in branches.values():
			for entry_data: Dictionary in branch_args[&"Entries"]:
				_fix_cutscene_command(entry_data)

func _fix_entry_lists_data() -> void:
	var debug_data: Dictionary = _e_data[&"Debug"][&"Data"]
	for key: StringName in [&"Dialogues", &"Stater", &"Cutscenes"]:
		for type: StringName in debug_data[key]:
			match type:
				&"Global": _fix_entry_lists_data_global(key, debug_data[key][type])
				&"Map": _fix_entry_lists_data_map(key, debug_data[key][type])

func _fix_entry_lists_data_global(_p_key: StringName, p_data: Dictionary) -> void:
	for key: StringName in p_data:
		var data: Array[Dictionary] = p_data[key][&"Data"]
		var new_data: Dictionary = {}
		for args: Dictionary in data:
			new_data[args[&"Name"]] = args
		p_data[key][&"Data"] = new_data

func _fix_entry_lists_data_map(p_key: StringName, p_data: Dictionary) -> void:
	p_data[&"Chapter_1"].erase(&"SV_SP_Sick_Apprentice_1")
	p_data[&"Chapter_1"].erase(&"Debug_1")
	p_data[&"Chapter_1"].erase(&"Ghost_House_1")
	p_data[&"Chapter_2"].erase(&"Broko_Town_1")
	for chapter: StringName in p_data:
		for location: StringName in p_data[chapter]:
			for key: StringName in p_data[chapter][location]:
				var data: Array[Dictionary] = p_data[chapter][location][key][&"Data"]
				var new_data: Dictionary = {}
				for args: Dictionary in data:
					if p_key == &"Dialogues" && args[&"Type"] == &"Text":
						var choice_data: Dictionary = args[&"Data"][&"Text"][&"Choice"]
						var entries_data: Array[Dictionary] = choice_data[&"Entries"]
						var new_entries_data: Dictionary = {}
						for entry_args: Dictionary in entries_data:
							new_entries_data[entry_args[&"Name"]] = entry_args
						choice_data[&"Entries"] = new_entries_data
						
						for choice_args: Dictionary in choice_data[&"Entries"].values():
							var conditions: Array[Dictionary] = choice_args[&"Conditions"]
							var new_conditions: Dictionary = {}
							for i: int in conditions.size():
								var conds_args: Dictionary = conditions[i]
								if !conds_args.has(&"Name"):
									conds_args[&"Name"] = str(i)
								new_conditions[conds_args[&"Name"]] = conds_args
							choice_args[&"Conditions"] = new_conditions
					
					if p_key == &"Stater":
						var conditions: Array[Dictionary] = args[&"Data"][&"Conditions"]
						var new_conditions: Dictionary = {}
						for cond_args: Dictionary in conditions:
							new_conditions[cond_args[&"Name"]] = cond_args
						args[&"Data"][&"Conditions"] = new_conditions
						
						var actions: Array[Dictionary] = args[&"Data"][&"Actions"]
						var new_actions: Dictionary = {}
						for action_args: Dictionary in actions:
							new_actions[action_args[&"Name"]] = action_args
						args[&"Data"][&"Actions"] = new_actions
					
					new_data[args[&"Name"]] = args
				p_data[chapter][location][key][&"Data"] = new_data

func _fix_stater_data() -> void:
	var stater_data: Dictionary = _e_data[&"Debug"][&"Data"][&"Stater"]
	_fix_stater_data_map(stater_data[&"Map"])

func _fix_stater_data_map(p_data: Dictionary) -> void:
	for chapter: StringName in p_data:
		for location: StringName in p_data[chapter]:
			for key: StringName in p_data[chapter][location]:
				var data: Dictionary = p_data[chapter][location][key]["Data"]
				for entry_key: StringName in data:
					var args: Dictionary = data[entry_key]
					
					var type: StringName = args[&"Type"]
					var old_data: Array[Dictionary] = args[&"Data"]
					var new_data: Dictionary = {}
					match type:
						&"General":
							new_data[&"General"] = old_data
							new_data[&"One_Time"] = {}
						&"One_Time":
							new_data[&"General"] = {}
							new_data[&"One_Time"] = old_data
					args[&"Data"] = new_data
					pass

#func _fix_cutscene_command(p_args: Dictionary) -> void:
	#var data: Dictionary = p_args["Data"]
	#var command: String = p_args["Command"]
	#match command:
		#"Change_Camera":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
		#
		#"Change_Dir":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Type", data["Type"])
			#for arg: String in data["Args"]:
				#_replace_option_data(data["Args"], arg, data["Args"][arg])
		#
		#"Change_Equipable":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Equipable_Group", data["Equipable_Group"])
			#_replace_option_data(data, "Equipable", data["Equipable"])
		#
		#"Change_Item_Amount":
			#data["Item"] = data["Item_Key"]
			#data.erase("Item_Key")
			#_replace_option_data(data, "Item", data["Item"])
			#data["Item"]["Stack"] = 99
			#data["Item"]["Image_Path"] = "res://Global_Resources/Sprites/Items/None.png"
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Amount", data["Amount"])
		#
		#"Change_State":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "State", data["State"])
		#
		#"Change_Visibility":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Visible", data["Visible"])
		#
		#"Comment":
			## Nothing to do
			#pass
		#
		#"Cond_Branch":
			#var branches: Dictionary = p_args["Args"]["Branches"]
			#for branch: int in branches:
				#var entries: Array[Dictionary] = branches[branch]["Entries"]
				#for entry_data: Dictionary in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Default_Object_Key":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
		#
		#"Disable_Object":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Disable", data["Disable"])
		#
		#"Exit_Cutscene":
			## No cutscene uses this command
			#pass
		#
		#"Jump":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#var selected: bool = data["Point"]["Selected"]
			#_replace_option_data(data, "Point", data["Point"]["Vec"])
			#data["Point"]["Selected"] = selected
			#_replace_option_data(data, "Keep_Dir", data["Keep_Dir"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Loop":
			#data["Args"]["Idx"] = data["Args"]["Idx_Ord"]
			#data["Args"].erase("Idx_Ord")
			#_replace_option_data(data["Args"], "Idx", data["Args"]["Idx"])
			#_replace_option_data(data["Args"], "Start", data["Args"]["Start"])
			#_replace_option_data(data["Args"], "End", data["Args"]["End"])
			#_replace_option_data(data["Args"], "Step", data["Args"]["Step"])
			#
			#var branches: Dictionary = p_args["Args"]["Branches"]
			#for branch: int in branches:
				#var entries: Array[Dictionary] = branches[branch]["Entries"]
				#for entry_data: Dictionary in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Match":
			#var branches: Dictionary = p_args["Args"]["Branches"]
			#for branch: int in branches:
				#var entries: Array[Dictionary] = branches[branch]["Entries"]
				#for entry_data: Dictionary in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Move_Free_Camera":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#data["Start_Object"]["Value"] = data["Start_Object"]["Key"]
			#data["Start_Object"].erase("Key")
			#_replace_option_data(data, "Start_Object", data["Start_Object"]["Value"])
			#data["End_Object"]["Value"] = data["End_Object"]["Key"]
			#data["End_Object"].erase("Key")
			#_replace_option_data(data, "End_Object", data["End_Object"]["Value"])
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Interpolate", data["Interpolate"])
			#_replace_option_data(data, "Speed", data["Speed"])
			#_replace_option_data(data, "Trans_Type", data["Trans_Type"])
			#_replace_option_data(data, "Ease_Type", data["Ease_Type"])
			#var selected: bool = data["Point"]["Selected"]
			#_replace_option_data(data, "Point", data["Point"]["Vec"])
			#data["Point"]["Selected"] = selected
			#_replace_option_data(data, "Change_Camera", data["Change_Camera"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Play_Anim":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Keep_Dir", data["Keep_Dir"])
			#_replace_option_data(data, "Backwards", data["Backwards"])
			#data["Anim_All"] = data["Anim_Name"]
			#_replace_option_data(data, "Anim_All", data["Anim_All"])
			#data["Anim_Keep_Dir"] = data["Anim_Name"]
			#_replace_option_data(data, "Anim_Keep_Dir", data["Anim_Keep_Dir"])
			#_replace_option_data(data, "Speed", data["Speed"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Play_Audio":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Audio_Type", data["Audio_Type"])
			#_replace_option_data(data, "Type", data["Type"])
			#data["Audio"] = data["Stream_Path"]
			#data.erase("Stream_Path")
			#_replace_option_data(data, "Audio", data["Audio"])
			#_replace_option_data(data, "Volume", data["Volume"])
			#_replace_option_data(data, "Pitch", data["Pitch"])
			#_replace_option_data(data, "Max_Distance", data["Max_Distance"])
			#var selected: bool = data["Point"]["Selected"]
			#_replace_option_data(data, "Point", data["Point"]["Vec"])
			#data["Point"]["Selected"] = selected
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Script":
			## Nothing to do
			#pass
		#
		#"Set_Move_Route":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "State", data["State"])
			#_replace_option_data(data, "Speed", data["Speed"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Show_Dialogue":
			#_replace_option_data(data, "Key", data["Key"])
			#_replace_option_data(data, "Key_Type", data["Key_Type"])
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Fade_Out", data["Fade_Out"])
		#
		#"Show_Overlay":
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Anim", data["Anim"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
			#_replace_option_data(data, "Mask", data["Mask"])
		#
		#"Show_Popup":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Sub_Process":
			#data["ID"] = data["Args"]["ID_Ord"]
			#data.erase("Args")
			#_replace_option_data(data, "ID", data["ID"])
			#
			#var branches: Dictionary = p_args["Args"]["Branches"]
			#for branch: int in branches:
				#var entries: Array[Dictionary] = branches[branch]["Entries"]
				#for entry_data: Dictionary in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Teleport":
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Teleportation", data["Teleportation"])
			#_replace_option_data(data, "Destination", data["Destination"])
			#_replace_option_data(data, "Handle_Lost_Battle", data["Handle_Lost_Battle"])
			#
			#var branches: Dictionary = p_args["Args"]["Branches"]
			#for branch: int in branches:
				#var entries: Array[Dictionary] = branches[branch]["Entries"]
				#for entry_data: Dictionary in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Teleport_Object":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#var selected: bool = data["Point"]["Selected"]
			#_replace_option_data(data, "Point", data["Point"]["Vec"])
			#data["Point"]["Selected"] = selected
		#
		#"Tween":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#_replace_option_data(data, "Comp", data["Comp"])
			#_replace_option_data(data, "Property", data["Property"])
			#_replace_option_data(data, "Interpolate", data["Interpolate"])
			#_replace_option_data(data, "Duration", data["Duration"])
			#_replace_option_data(data, "Trans_Type", data["Trans_Type"])
			#_replace_option_data(data, "Ease_Type", data["Ease_Type"])
			#_replace_option_data(data, "Start_Value", data["Start_Value"])
			#_replace_option_data(data, "End_Value", data["End_Value"])
			#_replace_option_data(data, "Wait_Finish", data["Wait_Finish"])
		#
		#"Wait":
			#data["Time"] = data["Value"]
			#data.erase("Value")
			#_replace_option_data(data, "Time", data["Time"])
		#
		#"Wait_For_Sub_Process":
			#data["ID"] = data["ID_Ord"]
			#data.erase("ID_Ord")
			#_replace_option_data(data, "ID", data["ID"])

#func _replace_option_data(p_data: Dictionary, p_key: String, p_value: Variant) -> void:
	#var dic: Dictionary = {}
	#dic["Type"] = "Value"
	#dic["Var"] = {}
	#dic["Var"]["Active"] = false
	#dic["Var"]["Expression"] = {}
	#var expr_data: Dictionary = dic["Var"]["Expression"]
	#expr_data["Instance_Key"] = ""
	#expr_data["Comp"] = ""
	#expr_data["Expression"] = ""
	#expr_data["Type"] = ""
	#dic["Value"] = p_value
	#
	#if p_data[p_key] is Dictionary && "Properties" in p_data[p_key]:
		#var properties: Dictionary = p_data[p_key]["Properties"]
		#p_data[p_key] = dic
		#p_data[p_key]["Properties"] = properties
	#else:
		#p_data[p_key] = dic

func write_data(p_key: StringName) -> void:
	var path: String = _e_data[p_key][&"Path"]
	var data: Dictionary = _e_data[p_key][&"Data"]
	Data_Parser.write_var_data(path, data)

func get_data(p_key: StringName) -> Dictionary:
	return _e_data[p_key][&"Data"]

func get_data_entry(p_key: StringName, p_entry_key: StringName) -> Resource:
	return _e_data[p_key][&"Data"][p_entry_key]

func get_debug_data(p_key: StringName) -> Dictionary:
	return _e_data[&"Debug"][&"Data"][p_key]

func get_teleport_data(p_args: Array[StringName]) -> DestinationDataBase:
	var data: Dictionary = get_data(&"Maps")
	var map_args: MapData = data[p_args[0]]
	var destinations: Dictionary = map_args.get_destinations()
	var dest_args: DestinationDataBase = destinations[p_args[1]]
	
	return dest_args

func get_global_map_data(p_key: StringName, p_key_type: StringName, p_chapter: StringName = &"",
						 p_location: StringName = &"", p_instance: Node = self) -> Dictionary:
	var data: Dictionary = get_debug_data(p_key)[p_key_type]
	if p_key_type == &"Map":
		if p_chapter == &"":
			var progress_si: Progress = Global.get_singleton(p_instance, "Progress")
			p_chapter = progress_si.get_chapter()
		if p_location == &"":
			var scene_manager_si: Scene_Manager = Global.get_singleton(p_instance, "Scene_Manager")
			p_location = scene_manager_si.get_location()
		data = data[p_chapter][p_location]
	
	return data
