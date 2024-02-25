
minetest.register_on_joinplayer(function(player)
	player:set_sky{
		base_color = "#777788",
		type = 'skybox',
		textures = {
			'oblx_skybox_up.png',
			'oblx_skybox_down.png',
			'oblx_skybox_west.png',
			'oblx_skybox_east.png',
			'oblx_skybox_north.png',
			'oblx_skybox_south.png',
		},
		clouds = false,
		body_orbit_tilt = -20,
	}

	player:set_sun{
		texture = "blank.png",
		visible = true,
		sunrise_visible = false
	}

	player:set_moon{
		visible = false
	}

	player:set_stars{
		visible = false
	}

	player:override_day_night_ratio(0.65)

	player:set_lighting{
		shadows = { intensity = 0.3 },
		saturation = 1
	}

	player:set_formspec_prepend([[
		bgcolor[#080808ff;true]
	]])

	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 9*3)
	player:get_inventory():set_size("craft", 0)
	player:get_inventory():set_size("craftpreview", 0)
	player:get_inventory():set_size("craftresult", 0)
	player:hud_set_hotbar_itemcount(9)
end)
