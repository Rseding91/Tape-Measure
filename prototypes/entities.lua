local baseArrow =
{
	type = "decorative",
	icon = "__Tape Measure__/graphics/null.png",
	flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "grass",
	order = "a",
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1, -1}, {1, 1}},
	selectable_in_game = false,
	render_layer = "object",
	pictures =
	{
		{
			filename = "__Tape Measure__/graphics/arrows.png",
			width = 64,
			height = 64,
			scale = 0.5
		}
	}
}

arrowLeft = util.table.deepcopy(baseArrow)
arrowRight = util.table.deepcopy(baseArrow)
arrowUp = util.table.deepcopy(baseArrow)
arrowDown = util.table.deepcopy(baseArrow)

arrowLeft["name"] = "arrow-left"
arrowRight["name"] = "arrow-right"
arrowUp["name"] = "arrow-up"
arrowDown["name"] = "arrow-down"

arrowLeft["pictures"][1].x = 64
arrowRight["pictures"][1].x = 192
arrowUp["pictures"][1].x = 128

data:extend({arrowLeft, arrowRight, arrowUp, arrowDown})

data:extend(
	{
		{
			type = "decorative",
			name = "tape-measure",
			icon = "__Tape Measure__/graphics/tape-measure.png",
			flags = {"placeable-neutral", "not-on-map"},
			subgroup = "grass",
			order = "a",
			collision_box = {{0, 0}, {0, 0}},
			selection_box = {{-1, -1}, {1, 1}},
			selectable_in_game = false,
			render_layer = "object",
			pictures =
			{
				{
					filename = "__Tape Measure__/graphics/tape-measure.png",
					width = 32,
					height= 32
				}
			}
		},
		{
			type = "decorative",
			name = "tape-measure-marker",
			icon = "__Tape Measure__/graphics/tape-measure-marker.png",
			flags = {"placeable-neutral", "not-on-map"},
			subgroup = "grass",
			order = "a",
			collision_box = {{0, 0}, {0, 0}},
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			selectable_in_game = false,
			render_layer = "object",
			pictures =
			{
				{
					filename = "__Tape Measure__/graphics/tape-measure-marker.png",
					width = 32,
					height= 32
				}
			}
		}
	}
)