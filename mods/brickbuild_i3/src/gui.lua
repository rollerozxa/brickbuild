local hotbar_len = i3.settings.hotbar_len

local PNG, styles, fs_elements, colors = i3.files.styles()

local sprintf = string.format

local round = i3.get("round")
local compression_active, compressible = i3.get("compression_active", "compressible")
local true_str = i3.get("true_str")

local trash = minetest.create_detached_inventory("i3_trash", {
	allow_put = function(_, _, _, stack)
		return stack:get_count()
	end,

	on_put = function(inv, listname, _, _, player)
		inv:set_list(listname, {})
	end,
})

trash:set_size("main", 1)

local function fmt(elem, ...)
	if not fs_elements[elem] then
		return sprintf(elem, ...)
	end

	return sprintf(fs_elements[elem], ...)
end

local function get_inv_slots(fs)
	local inv_x = 0.22
	local inv_y = 6.9
	local size, spacing = 1, 0.1

	fs"style_type[box;colors=#777]"

	for i = 0, hotbar_len - 1 do
		fs("box", i * size + inv_x + (i * spacing), inv_y, size, size, "")
	end

	fs(fmt("style_type[list;size=%f;spacing=%f]", size, spacing),
	   fmt("list[current_player;main;%f,%f;%u,1;]", inv_x, inv_y, hotbar_len))

	fs(fmt("style_type[list;size=%f;spacing=%f]", size, spacing),
	   fmt("list[current_player;main;%f,%f;%u,%u;%u]", inv_x, inv_y + 1.15,
		hotbar_len, i3.settings.inv_size / hotbar_len, hotbar_len),
	   "style_type[list;size=1;spacing=0.15]")

	fs"listring[current_player;craft]listring[current_player;main]"
end

local function get_inventory_fs(player, data, fs)
	fs"listcolors[#bababa50;#bababa99]"

	get_inv_slots(fs)

	local props = player:get_properties()
	local ctn_len, ctn_hgt = 5.7, 6.3

	if props.mesh ~= "" then
		local anim = player:get_local_animation()
		local t = {}

		for _, v in ipairs(props.textures) do
			table.insert(t, (minetest.formspec_escape(v):gsub(",", "!")))
		end

		local textures = table.concat(t, ","):gsub("!", ",")

		fs("model", 0.2, 0.2, 3.4, ctn_hgt,
			"player_model", props.mesh, textures, "0,-150", "false", "false",
			fmt("%u,%u", anim.x, anim.y))
	else
		local size = 2.5
		fs("image", 0.7, 0.2, size, size * props.visual_size.y, props.textures[1])
	end

	fs(fmt("container[3.9,0.2;%f,%f;scrbar_inv;vertical]", ctn_len, ctn_hgt))

	fs("style[player_name;font=bold;font_size=22]")
	fs("button", 0, 0, ctn_len, 0.5, "player_name", minetest.formspec_escape(data.player_name))
	fs("box", 0, 0.55, ctn_len, 0.035, "#fafafa")
	fs("list[detached:i3_trash;main;4.45,0.75;1,1;]")
	fs("image", 4.45, 1.25 - 0.5, 1, 1, PNG.trash)

	fs"container_end[]"
end

local function hide_items(player, data)
	if compression_active(data) then
		local new = {}

		for i = 1, #data.items do
			local item = data.items[i]
			if not i3.compressed[item] then
				table.insert(new, item)
			end
		end

		data.items = new
	end

	if not minetest.is_creative_enabled(data.player_name) then
		local new = {}

		data.items = new
	end
end

local function get_items_fs(fs, data, player, full_height)
	hide_items(player, data)

	local items = data.alt_items or data.items or {}
	local rows, lines = 8, 12
	local ipp = rows * lines
	local size = 0.85

	fs("bg9", data.inv_width + 0.1, 0, 7.9, full_height, PNG.bg_full, 10)

	fs(fmt("box[%f,0.2;4.05,0.6;#bababa25]", data.inv_width + 0.3),
	   "set_focus[filter]",
	   fmt("field[%f,0.2;2.95,0.6;filter;;%s]", data.inv_width + 0.35, minetest.formspec_escape(data.filter)),
	   "field_close_on_enter[filter;false]")

	fs("image_button", data.inv_width + 3.35, 0.35, 0.3,  0.3,  "", "cancel", "")
	fs("image_button", data.inv_width + 3.85, 0.32, 0.35, 0.35, "", "search", "")
	fs("image_button", data.inv_width + 5.27, 0.3,  0.35, 0.35, "", "prev_page", "")
	fs("image_button", data.inv_width + 7.45, 0.3,  0.35, 0.35, "", "next_page", "")

	data.pagemax = math.max(1, math.ceil(#items / ipp))

	fs("button", data.inv_width + 5.6, 0.14, 1.88, 0.7, "pagenum",
		fmt("%s / %u", minetest.colorize(colors.yellow, data.pagenum), data.pagemax))

	if #items == 0 then
		local lbl = "No item to show"

		if minetest.sha1(data.filter) == "7f7342b806f4d8dfb16e57ce289ee8cf72d5aa37" then
			lbl = "uwu"
		end

		fs("button", data.inv_width + 0.1, 3, 8, 1, "no_item", lbl)
		return
	end

	local first_item = (data.pagenum - 1) * ipp

	for i = first_item, first_item + ipp - 1 do
		local item = items[i + 1]
		if not item then break end

		local _compressed = item:sub(1, 1) == "_"
		local name = _compressed and item:sub(2) or item

		local X = i % rows
				X = X - (X * 0.045) + data.inv_width + 0.28

		local Y = round((i % ipp - X) / rows + 1, 0)
				Y = Y - (Y * 0.085) + 0.95

		table.insert(fs, fmt("item_image_button", X, Y, size, size, name, item, ""))

		if compressible(item, data) then
			local expand = data.expand == name

			fs(fmt("tooltip[%s;%s]", item, expand and "Click to hide" or "Click to expand"))
			fs"style_type[label;font=bold;font_size=20]"
			fs("label", X + 0.65, Y + 0.7, expand and "-" or "+")
			fs"style_type[label;font=normal;font_size=16]"
		end
	end
end

local function get_tabs_fs(fs, player, data, full_height)
	local tab_len, tab_hgh, c, over = 3, 0.5, 0
	local _tabs = table.copy(i3.tabs)

	for i, def in ipairs(i3.tabs) do
		if def.access and not def.access(player, data) then
			table.remove(_tabs, i)
		end
	end

	local shift = math.min(3, #_tabs)

	for i, def in ipairs(_tabs) do
		if not over and c > 2 then
			over = true
			c = 0
		end

		local btm = i <= 3

		if not btm then
			shift = #_tabs - 3
		end

		local selected = i == data.tab

		fs(fmt([[style_type[image_button;fgimg=%s;fgimg_hovered=%s;noclip=true;
			font_size=16;textcolor=%s;content_offset=0] ]],
		selected and (btm and PNG.tab_hover or PNG.tab_hover_top) or (btm and PNG.tab or PNG.tab_top),
		btm and PNG.tab_hover or PNG.tab_hover_top, selected and "#fff" or "#ddd"))

		local X = (data.inv_width / 2) + (c * (tab_len + 0.1)) - ((tab_len + 0.05) * (shift / 2))
		local Y = btm and full_height or -tab_hgh

		fs"style_type[image_button:hovered;textcolor=#fff]"
		fs("image_button", X, Y, tab_len, tab_hgh, "", fmt("tab_%s", def.name), minetest.formspec_escape(def.description))

		if true_str(def.image) then
			local desc = minetest.get_translated_string(data.lang_code, def.description)
			fs("style_type[image;noclip=true]")
			fs("image", X + (tab_len / 2) - ((#desc * 0.1) / 2) - 0.55,
				Y + 0.05, 0.35, 0.35, fmt("%s^\\[resize:16x16", def.image))
		end

		c = c + 1
	end
end

local function make_fs(player, data)
	local fs = setmetatable({}, {
		__call = function(t, ...)
			local args = {...}
			local elem = fs_elements[args[1]]

			if elem then
				table.insert(t, fmt(elem, select(2, ...)))
			else
				table.insert(t, table.concat(args))
			end
		end
	})

	data.inv_width = 10.23
	local full_height = 12

	fs(fmt("formspec_version[4]size[%f,%f]padding[0,0]no_prepend[]bgcolor[#0000]",
		data.inv_width + 8, full_height), styles)

	fs("bg9", 0, 0, data.inv_width, full_height, PNG.bg_full, 10)

	local tab = i3.tabs[data.tab]
	if tab then
		tab.formspec(player, data, fs)
	end

	get_items_fs(fs, data, player, full_height)

	if #i3.tabs > 1 then
		get_tabs_fs(fs, player, data, full_height)
	end

	return table.concat(fs)
end

return make_fs, get_inventory_fs
