
local animations = {
	-- Standard animations.
	stand     = {x = 0,   y = 79},
	lay       = {x = 162, y = 166},
	walk      = {x = 168, y = 187},
	mine      = {x = 189, y = 198},
	walk_mine = {x = 200, y = 219},
	sit       = {x = 81,  y = 160},
}

local player_anim = {}
local player_sneak = {}

core.register_on_joinplayer(function(player)
	player:set_properties{
		mesh = "character.b3d",
		textures = {"character.png"},
		visual = "mesh",
		visual_size = {x = 2.25, y = 2.25},
		collisionbox = {-0.7, 0.0, -0.3, 0.3, 3.6, 0.7},
		stepheight = 2.5,
		eye_height = 3.25,
	}

	player:set_local_animation(
		animations.stand,
		animations.walk,
		animations.mine,
		animations.walk_mine,
		35)

	player:override_day_night_ratio(1)

	player:set_physics_override{
		speed = 3,
		jump = 2,
		gravity = 2
	}
end)

core.register_globalstep(function()
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local controls = player:get_player_control()

		local anim_speed = controls.sneak and 15 or 30
		local anim_name

		if controls.up or controls.down or controls.left or controls.right then
			if player_sneak[name] ~= controls.sneak then
				player_anim[name] = nil
				player_sneak[name] = controls.sneak
			end

			if controls.LMB or controls.RMB then
				anim_name = "walk_mine"
			else
				anim_name = "walk"
			end
		elseif controls.LMB or controls.RMB then
			anim_name = "mine"
		else
			anim_name = "stand"
		end

		if player_anim[name] == anim_name then return end

		player_anim[name] = anim_name
		player:set_animation(animations[anim_name], anim_speed)
	end
end)
