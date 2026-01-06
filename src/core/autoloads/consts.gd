extends Node

enum SCENE_NAME {
	SPLASH,
	MAIN_MENU,
	GAME,
	WIN,
	GAME_OVER,
}

const INPUT = {
	"PLAYER": {
		"MOVE": {
			"UP": "player_move_up",
			"DOWN": "player_move_down",
			"LEFT": "player_move_left",
			"RIGHT": "player_move_right",
		},
		"AIM": {
			"UP": "player_aim_up",
			"DOWN": "player_aim_down",
			"LEFT": "player_aim_left",
			"RIGHT": "player_aim_right",
		},
		"SHOOT": "player_shoot",
	}
}

const INT = {
	"MAX": 9223372036854775807,
	"MIN": -9223372036854775808,
}

const MAX_COLLISION_LAYERS = 32

enum COLLISION_LAYERS {
	Player = 1,
	Enemies = 2,
	Obstacles = 3,
	PickupItems = 4,
	PlayerProjectiles = 5
}
