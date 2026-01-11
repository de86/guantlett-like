extends Node

# Scenes
signal splash_complete
signal scene_root_node_ready(scene_root_node:Node)
signal switch_scene(new_scene:PackedScene, options:Dictionary[StringName, Variant])
signal scene_changed(new_scene_name:StringName, new_scene:PackedScene)


# Game Settings
signal game_settings_music_volume_change(new_value:int)
signal game_settings_sfx_volume_change(new_value:int)


# Gameplay
signal player_exited_floor
signal player_collected_item(item:SimpleItemDef)
signal player_used_key
signal player_health_changed(new_value:int)
signal player_died()
signal points_scored(points:int)
signal player_score_changed(score:int)
