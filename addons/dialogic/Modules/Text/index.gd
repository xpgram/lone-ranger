@tool
extends DialogicIndexer


func _get_events() -> Array:
	return [this_folder.path_join('event_text.gd')]


func _get_subsystems() -> Array:
	return [{'name':'Text', 'script':this_folder.path_join('subsystem_text.gd')}]


func _get_settings_pages() -> Array:
	return [this_folder.path_join('settings_text.tscn')]


func _get_character_editor_sections() -> Array:
	return [this_folder.path_join('character_settings/character_moods_settings.tscn'),
		this_folder.path_join('character_settings/character_portrait_mood_settings.tscn'),
	]


func _get_text_effects() -> Array[Dictionary]:
	return [
		{'command':'speed', 'subsystem':'Text', 'method':'effect_speed', 'arg':true},
		{'command':'sedate', 'subsystem':'Text', 'method':'effect_speed_sedate', 'arg':false},
		{'command':'slow', 'subsystem':'Text', 'method':'effect_speed_slow', 'arg':false},
		{'command':'stutter', 'subsystem':'Text', 'method':'effect_speed_slow', 'arg':false},
		{'command':'steady', 'subsystem':'Text', 'method':'effect_speed_steady', 'arg':false},
		{'command':'quick', 'subsystem':'Text', 'method':'effect_speed_quick', 'arg':false},
		{'command':'fast', 'subsystem':'Text', 'method':'effect_speed_fast', 'arg':false},

		{'command':'lspeed', 'subsystem':'Text', 'method':'effect_lspeed', 'arg':true},

		{'command':'pause', 'subsystem':'Text', 'method':'effect_pause', 'arg':true},
		{'command':'p', 'subsystem':'Text', 'method':'effect_pause', 'arg':true},
		{'command':'pb', 'subsystem':'Text', 'method':'effect_pause_breve', 'arg':false},
		{'command':'pb.', 'subsystem':'Text', 'method':'effect_pause_breve_dot', 'arg':false},
		{'command':'pl', 'subsystem':'Text', 'method':'effect_pause_longa', 'arg':false},
		{'command':'pl.', 'subsystem':'Text', 'method':'effect_pause_longa_dot', 'arg':false},
		{'command':'p1', 'subsystem':'Text', 'method':'effect_pause_whole', 'arg':false},
		{'command':'p1.', 'subsystem':'Text', 'method':'effect_pause_whole_dot', 'arg':false},
		{'command':'p2', 'subsystem':'Text', 'method':'effect_pause_half', 'arg':false},
		{'command':'p2.', 'subsystem':'Text', 'method':'effect_pause_half_dot', 'arg':false},
		{'command':'p3', 'subsystem':'Text', 'method':'effect_pause_third', 'arg':false},
		{'command':'p3.', 'subsystem':'Text', 'method':'effect_pause_third_dot', 'arg':false},
		{'command':'p4', 'subsystem':'Text', 'method':'effect_pause_quarter', 'arg':false},
		{'command':'p4.', 'subsystem':'Text', 'method':'effect_pause_quarter_dot', 'arg':false},
		{'command':'p8', 'subsystem':'Text', 'method':'effect_pause_eighth', 'arg':false},
		{'command':'p8.', 'subsystem':'Text', 'method':'effect_pause_eighth_dot', 'arg':false},
		{'command':'p16', 'subsystem':'Text', 'method':'effect_pause_sixteenth', 'arg':false},
		{'command':'p16.', 'subsystem':'Text', 'method':'effect_pause_sixteenth_dot', 'arg':false},

		{'command':'signal', 'subsystem':'Text', 'method':'effect_signal', 'arg':true},
		{'command':'mood', 'subsystem':'Text', 'method':'effect_mood', 'arg':true},
	]


func _get_text_modifiers() -> Array[Dictionary]:
	return [
		{'subsystem':'Text', 'method':'modifier_autopauses'},
		{'subsystem':'Text', 'method':'modifier_random_selection', 'mode':-1},
		{'subsystem':'Text', 'method':"modifier_break", 'command':'br', 'mode':-1},
	]
