
local PNG = {
	blank = "blank.png",
	bg_full = "i3_bg_full.png",
	search = "i3_search.png",
	prev = "i3_next.png^\\[transformFX",
	next = "i3_next.png",
	trash = "i3_trash.png",
	cancel = "i3_cancel.png",
	slot = "i3_slot.png",

	cancel_hover = "i3_cancel.png^\\[brighten",
	search_hover = "i3_search.png^\\[brighten",
	trash_hover = "i3_trash.png^\\[brighten^\\[colorize:#f00:100",
	prev_hover = "i3_next_hover.png^\\[transformFX",
	next_hover = "i3_next_hover.png",
}

local styles = string.format([[
	style_type[field;border=false;bgcolor=transparent]
	style_type[label,field;font_size=16]
	style_type[button;border=false;content_offset=0]
	style_type[image_button,item_image_button,dropdown;border=false]
	style_type[item_image_button;bgimg_hovered=%s]

	style[pagenum,no_item;font=bold;font_size=18]
	style[cancel;fgimg=%s;fgimg_hovered=%s;content_offset=0]
	style[search;fgimg=%s;fgimg_hovered=%s;content_offset=0]
	style[prev_page;fgimg=%s;fgimg_hovered=%s]
	style[next_page;fgimg=%s;fgimg_hovered=%s]
]],
PNG.slot,
PNG.cancel, PNG.cancel_hover,
PNG.search, PNG.search_hover,
PNG.prev,   PNG.prev_hover,
PNG.next,   PNG.next_hover)

local fs_elements = {
	label = "label[%f,%f;%s]",
	box = "box[%f,%f;%f,%f;%s]",
	image = "image[%f,%f;%f,%f;%s]",
	tooltip = "tooltip[%f,%f;%f,%f;%s]",
	button = "button[%f,%f;%f,%f;%s;%s]",
	bg9 = "background9[%f,%f;%f,%f;%s;false;%u]",
	image_button = "image_button[%f,%f;%f,%f;%s;%s;%s]",
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
}

local compression_active, compressible = i3.get("compression_active", "compressible")

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
		return string.format(elem, ...)
	end

	return string.format(fs_elements[elem], ...)
end

local function get_inventory_fs(player, data, fs)
	fs"listcolors[#bababa50;#bababa99]"

	local hotbar_len = 9

	local inv_x = 0.22
	local inv_y = 7.85
	local size, spacing = 1, 0.1

	fs"style_type[box;colors=#777]"

	for i = 0, hotbar_len - 1 do
		fs("box", i * size + inv_x + (i * spacing), inv_y, size, size, "")
	end

	fs(fmt("style_type[list;size=%f;spacing=%f]", size, spacing),
	   fmt("list[current_player;main;%f,%f;%u,1;]", inv_x, inv_y, hotbar_len))

	fs(fmt("style_type[list;size=%f;spacing=%f]", size, spacing),
	   fmt("list[current_player;main;%f,%f;%u,%u;%u]", inv_x, inv_y + 1.15,
		hotbar_len, (4*9) / hotbar_len, hotbar_len),
	   "style_type[list;size=1;spacing=0.15]")

	--fs("list[detached:i3_trash;main;4.45,0.75;1,1;]")
	--fs("image", 4.45, 1.25 - 0.5, 1, 1, PNG.trash)
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
	local rows, lines = 10, 7
	local ipp = rows * lines
	local size = 0.85

	fs(fmt("box[%f,0.2;4.05,0.6;#bababa25]", 0.3),
	   "set_focus[filter]",
	   fmt("field[%f,0.2;2.95,0.6;filter;;%s]", 0.35, minetest.formspec_escape(data.filter)),
	   "field_close_on_enter[filter;false]")

	fs("image_button", 3.35, 0.35, 0.3,  0.3,  "", "cancel", "")
	fs("image_button", 3.85, 0.32, 0.35, 0.35, "", "search", "")
	fs("image_button", 7.27, 0.3,  0.35, 0.35, "", "prev_page", "")
	fs("image_button", 9.45, 0.3,  0.35, 0.35, "", "next_page", "")

	data.pagemax = math.max(1, math.ceil(#items / ipp))

	fs("button", 7.6, 0.14, 1.88, 0.7, "pagenum",
		fmt("%s / %u", minetest.colorize("#ffd866", data.pagenum), data.pagemax))

	if #items == 0 then
		local lbl = "No item to show"

		if minetest.sha1(data.filter) == "7f7342b806f4d8dfb16e57ce289ee8cf72d5aa37" then
			lbl = "uwu"
		end

		fs("button", 0.1, 3, 8, 1, "no_item", lbl)
		return
	end

	local first_item = (data.pagenum - 1) * ipp

	for i = first_item, first_item + ipp - 1 do
		local item = items[i + 1]
		if not item then break end

		local _compressed = item:sub(1, 1) == "_"
		local name = _compressed and item:sub(2) or item

		local X = i % rows
				X = X - (X * 0.025) + 0.28

		local Y = math.floor((i % ipp - X) / rows + 2)
				Y = Y - (Y * 0.085) + 0.15

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

	local inv_width = 10.23
	local full_height = 11.4

	fs(fmt("formspec_version[4]size[%f,%f]padding[0,0]no_prepend[]bgcolor[#0000]",
		inv_width, full_height), styles)

	fs("bg9", 0, 0, inv_width, full_height, PNG.bg_full, 10)

	get_inventory_fs(player, data, fs)

	get_items_fs(fs, data, player, full_height)

	return table.concat(fs)
end

return make_fs
