
local function lf(path)
	return assert(loadfile(minetest.get_modpath("brickbuild_i3") .. path))
end

i3 = {
	data = {},

	settings = {
	},

	categories = {
	},
	files = {
		api = lf"/src/api.lua",
		callbacks = lf"/src/callbacks.lua",
		common = lf"/src/common.lua",
		fields = lf"/src/fields.lua",
		gui = lf"/src/gui.lua",
		styles = lf"/src/styles.lua",
	},

	-- Caches
	init_items = {},

	tabs = {},

	recipe_filters = {},
	search_filters = {},

	compress_groups = {},
	compressed = {}
}

i3.settings.hotbar_len = 9
i3.settings.inv_size   = 4 * i3.settings.hotbar_len

i3.files.common()
i3.files.api()
i3.files.callbacks()
