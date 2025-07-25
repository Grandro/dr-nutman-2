extends Node

signal data_loaded()

@export var _e_data: Dictionary = {}

func _ready():
	_init_data()

func _init_data():
#	var config = ConfigFile.new()
#	var err = config.load("res://DEBUG_DATA.cfg")
#	var data = config.get_value("Data", "Data")
#	var debug_data = data["Debug"]["Data"]
#	Data_Parser.write_var_data("res://Data/Debug.dat", debug_data)
	
	var path = _e_data["Debug"]["Path"]
	_e_data["Debug"]["Data"] = Data_Parser.load_var_data(path)
	print(_e_data["Debug"]["Data"]["Stater"]["Map"].keys())
	
	#_fix_entry_lists_data()
	#_fix_cutscenes_data()
	#_fix_stater_data()
	
	#var cutscenes_data = _e_data["Debug"]["Data"]["Cutscenes"]
	#var map_data = cutscenes_data["Map"]
	#for chapter in map_data:
		#for location in map_data[chapter]:
			#for key in map_data[chapter][location]:
				#var cutscene_data = map_data[chapter][location][key]["Data"]
				#for commands_args in cutscene_data:
					#var commands_data = commands_args["Data"]["Default"]
					#for command_args in commands_data:
						#var command = command_args["Command"]
						#if command == "Match":
							#var command_data = command_args["Data"]
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
						
						#var command_data = command_args["Data"]
						#if command_data.has("Object"):
							#var object_data = command_data["Object"]
							#if !object_data.has("Properties"):
								#object_data["Properties"] = {}
							#if !object_data.has("Equipables"):
								#object_data["Equipables"] = {}
	
	#var chapter_1_data = _e_data["Debug"]["Data"]["Cutscenes"]["Map"]["Chapter_1"]
	#for location in chapter_1_data:
		#for key in chapter_1_data[location]:
			#var cutscene_data = chapter_1_data[location][key]["Data"]
			#for commands_args in cutscene_data:
				#var commands_data = commands_args["Data"]
				#commands_args["Data"] = {}
				#commands_args["Data"]["Default"] = commands_data
				#for command_args in commands_data:
					#_fix_cutscene_command(command_args)
	
	#var stater_data = _e_data["Debug"]["Data"]["Stater"]
	#var chapter_1_data = stater_data["Map"]["Chapter_1"]
	#for location in chapter_1_data:
		#for object_key in chapter_1_data[location]:
			#var data = chapter_1_data[location][object_key]
			#for args in data["Data"]:
				#for actions_data in args["Data"]["Actions"]:
					#for actions_args in actions_data:
						#_fix_cutscene_command(actions_args)
	
	#var chapter_1_data = _e_data["Debug"]["Data"]["Cutscenes"]["Map"]["Chapter_1"]
	#for location in chapter_1_data:
		#for key in chapter_1_data[location]:
			#var cutscene_data = chapter_1_data[location][key]["Data"]
			#for commands_args in cutscene_data:
				#var commands_data = commands_args["Data"]
				#for command_args in commands_data:
					#_fix_cutscene_command(command_args)
	
	#var chapter_1_d1ata = _e_data["Debug"]["Data"]["Cutscenes"]["Map"]["Chapter_1"]["Doctor_Dream_1"]
	
	data_loaded.emit()

func _fix_cutscenes_data():
	var cutscenes_data = _e_data["Debug"]["Data"]["Cutscenes"]
	var map_data = cutscenes_data["Map"]
	for chapter in map_data:
		for location in map_data[chapter]:
			for key in map_data[chapter][location]:
				var cutscene_data = map_data[chapter][location][key]["Data"]
				for commands_args in cutscene_data.values():
					var commands_data = commands_args["Data"]["Default"]
					for command_args in commands_data:
						_fix_cutscene_command(command_args)
	
	var global_data = cutscenes_data["Global"]
	for key in global_data:
		var cutscene_data = global_data[key]["Data"]
		for commands_args in cutscene_data.values():
			var commands_data = commands_args["Data"]["Default"]
			for command_args in commands_data:
				_fix_cutscene_command(command_args)

func _fix_cutscene_command(p_args):
	var _command = p_args["Command"]
	var _command_data = p_args["Data"]
	
	if p_args["Args"].has("Branches"):
		var branches = p_args["Args"]["Branches"]
		for branch in branches:
			branches[int(branch)] = branches[branch]
		for branch in branches:
			branches.erase(str(branch))
		for branch_args in branches.values():
			for entry_data in branch_args["Entries"]:
				_fix_cutscene_command(entry_data)

func _fix_entry_lists_data():
	var debug_data = _e_data["Debug"]["Data"]
	for key in ["Dialogues", "Stater", "Cutscenes"]:
		for type in debug_data[key]:
			match type:
				"Global": _fix_entry_lists_data_global(key, debug_data[key][type])
				"Map": _fix_entry_lists_data_map(key, debug_data[key][type])

func _fix_entry_lists_data_global(p_key, p_data):
	for key in p_data:
		var data = p_data[key]["Data"]
		var new_data = {}
		for args in data:
			if p_key == "Dialogues" && args["Type"] == "Text":
				var choice_data = args["Data"]["Choice"]
				if !choice_data.is_empty():
					pass
			
			if new_data.has(args["Name"]):
				pass
			if args["Name"].is_empty():
				pass
			new_data[args["Name"]] = args
		p_data[key]["Data"] = new_data

func _fix_entry_lists_data_map(p_key, p_data):
	p_data["Chapter_1"].erase("SV_SP_Sick_Apprentice_1")
	p_data["Chapter_1"].erase("Debug_1")
	p_data["Chapter_1"].erase("Ghost_House_1")
	p_data["Chapter_2"].erase("Broko_Town_1")
	for chapter in p_data:
		for location in p_data[chapter]:
			for key in p_data[chapter][location]:
				var data = p_data[chapter][location][key]["Data"]
				var new_data = {}
				for args in data:
					if p_key == "Dialogues" && args["Type"] == "Text":
						var choice_data = args["Data"]["Text"]["Choice"]
						var entries_data = choice_data["Entries"]
						var new_entries_data = {}
						for entry_args in entries_data:
							if new_entries_data.has(entry_args["Name"]):
								pass
							if entry_args["Name"].is_empty():
								pass
							new_entries_data[entry_args["Name"]] = entry_args
						choice_data["Entries"] = new_entries_data
						
						for choice_args in choice_data["Entries"].values():
							var conditions = choice_args["Conditions"]
							var new_conditions = {}
							for i in conditions.size():
								var conds_args = conditions[i]
								if !conds_args.has("Name"):
									conds_args["Name"] = str(i)
								if new_conditions.has(conds_args["Name"]):
									pass
								if conds_args["Name"].is_empty():
									pass
								new_conditions[conds_args["Name"]] = conds_args
							choice_args["Conditions"] = new_conditions
					
					if p_key == "Stater":
						var conditions = args["Data"]["Conditions"]
						var new_conditions = {}
						for cond_args in conditions:
							if new_conditions.has(cond_args["Name"]):
								pass
							if cond_args["Name"].is_empty():
								pass
							new_conditions[cond_args["Name"]] = cond_args
						args["Data"]["Conditions"] = new_conditions
						
						var actions = args["Data"]["Actions"]
						var new_actions = {}
						for action_args in actions:
							if new_actions.has(action_args["Name"]):
								pass
							if action_args["Name"].is_empty():
								pass
							new_actions[action_args["Name"]] = action_args
						args["Data"]["Actions"] = new_actions
					
					if new_data.has(args["Name"]):
						pass
					if args["Name"].is_empty():
						pass
					new_data[args["Name"]] = args
				p_data[chapter][location][key]["Data"] = new_data

func _fix_stater_data():
	var stater_data = _e_data["Debug"]["Data"]["Stater"]
	_fix_stater_data_map(stater_data["Map"])

func _fix_stater_data_map(p_data):
	for chapter in p_data:
		for location in p_data[chapter]:
			for key in p_data[chapter][location]:
				var data = p_data[chapter][location][key]["Data"]
				for entry_key in data:
					var args = data[entry_key]
					
					var type = args["Type"]
					var old_data = args["Data"]
					var new_data = {}
					if type == "General":
						new_data["General"] = old_data
						new_data["One_Time"] = {}
					elif type == "One_Time":
						new_data["General"] = {}
						new_data["One_Time"] = old_data
					args["Data"] = new_data
					pass

#func _fix_cutscene_command(p_args):
	#return
	#var data = p_args["Data"]
	#var command = p_args["Command"]
	#match command:
		#"Set_Cutscene_Args":
			#p_args["Command"] = "Change_Cutscene_Args"
		#"Set_Dialogue_Args":
			#p_args["Command"] = "Change_Dialogue_Args"

#func _fix_cutscene_command(p_args):
	#return
	#var data = p_args["Data"]
	#var command = p_args["Command"]
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
			#for arg in data["Args"]:
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
			#var branches = p_args["Args"]["Branches"]
			#for branch in branches:
				#var entries = branches[branch]["Entries"]
				#for entry_data in entries:
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
			#var selected = data["Point"]["Selected"]
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
			#var branches = p_args["Args"]["Branches"]
			#for branch in branches:
				#var entries = branches[branch]["Entries"]
				#for entry_data in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Match":
			#var branches = p_args["Args"]["Branches"]
			#for branch in branches:
				#var entries = branches[branch]["Entries"]
				#for entry_data in entries:
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
			#var selected = data["Point"]["Selected"]
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
			#var selected = data["Point"]["Selected"]
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
			#var branches = p_args["Args"]["Branches"]
			#for branch in branches:
				#var entries = branches[branch]["Entries"]
				#for entry_data in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Teleport":
			#_replace_option_data(data, "Type", data["Type"])
			#_replace_option_data(data, "Teleportation", data["Teleportation"])
			#_replace_option_data(data, "Destination", data["Destination"])
			#_replace_option_data(data, "Handle_Lost_Battle", data["Handle_Lost_Battle"])
			#
			#var branches = p_args["Args"]["Branches"]
			#for branch in branches:
				#var entries = branches[branch]["Entries"]
				#for entry_data in entries:
					#_fix_cutscene_command(entry_data)
		#
		#"Teleport_Object":
			#data["Object"]["Value"] = data["Object"]["Key"]
			#data["Object"].erase("Key")
			#_replace_option_data(data, "Object", data["Object"]["Value"])
			#var selected = data["Point"]["Selected"]
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

#func _replace_option_data(p_data, p_key, p_value):
	#var dic = {}
	#dic["Type"] = "Value"
	#dic["Var"] = {}
	#dic["Var"]["Active"] = false
	#dic["Var"]["Expression"] = {}
	#var expr_data = dic["Var"]["Expression"]
	#expr_data["Instance_Key"] = ""
	#expr_data["Comp"] = ""
	#expr_data["Expression"] = ""
	#expr_data["Type"] = ""
	#dic["Value"] = p_value
	#
	#if p_data[p_key] is Dictionary && "Properties" in p_data[p_key]:
		#var properties = p_data[p_key]["Properties"]
		#p_data[p_key] = dic
		#p_data[p_key]["Properties"] = properties
	#else:
		#p_data[p_key] = dic

func write_data(p_key):
	var path = _e_data[p_key]["Path"]
	var data = _e_data[p_key]["Data"]
	Data_Parser.write_var_data(path, data)

func get_data(p_key):
	return _e_data[p_key]["Data"]

func get_data_entry(p_key, p_entry_key):
	return _e_data[p_key]["Data"][p_entry_key]

func get_debug_data(p_key):
	return _e_data["Debug"]["Data"][p_key]

func get_teleport_data(p_args):
	var data = get_data("Maps")
	for i in 3:
		match i:
			0: data = data[p_args[0]]
			1: data = data.get_destinations()
			2: data = data[p_args[1]]
	
	return data

func get_global_map_data(p_key, p_key_type, p_chapter = "", p_location = "", p_instance = self):
	var data = get_debug_data(p_key)[p_key_type]
	if p_key_type == "Map":
		if p_chapter.is_empty():
			var progress_si = Global.get_singleton(p_instance, "Progress")
			p_chapter = progress_si.get_chapter()
		if p_location.is_empty():
			var scene_manager_si = Global.get_singleton(p_instance, "Scene_Manager")
			p_location = scene_manager_si.get_location()
		data = data[p_chapter][p_location]
	
	return data
