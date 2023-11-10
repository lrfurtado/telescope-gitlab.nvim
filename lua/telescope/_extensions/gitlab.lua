local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This plugins requires nvim-telescope/telescope.nvim")
end

local has_glab = vim.fn.executable("glab") == 1
if not has_glab then
	error("This plugin requires the glab binary")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local utils = require("telescope.utils")

local glab_command = function(args, opts)
	opts = opts or {}

	opts.verb = opts.verb or "GET"

	local _args = { "glab", "api" }
	if opts.verb then
		vim.list_extend(_args, { "-X", opts.verb })
	end

	if opts.fields then
		for k, v in pairs(opts.fields) do
			table.insert(_args, "-f")
			table.insert(_args, string.format("%s=%s", k, v))
		end
	end

	return vim.list_extend(_args, args)
end

local get_glab_command_json = function(args, opts)
	return utils.get_os_command_output(glab_command(args, opts), opts.cwd, opts.timeout)
end

local glab_issues = function(opts)
	opts = opts or {}
	output = get_glab_command_json({ "/issues" }, opts)

	o = vim.json.decode(output[1])
	issues = {}
	for _, v in ipairs(o) do
		if v.state == "closed" then
			state = "😀(closed)"
		else
			state = "💩(open)  "
		end
		v.funny_state = state
		table.insert(issues, v)
	end
	pickers
		.new(opts, {
			prompt_title = "Glab Issues",
			finder = finders.new_table({
				results = issues,
			}),
			sorter = conf.generic_sorter(opts),
			entry_maker = function(entry)
				content = string.format("%-42s", entry.references.full)
					.. "|"
					.. entry.funny_state
					.. "|"
					.. entry.title
				return {
					value = entry,
					display = content,
					ordinal = content,
				}
			end,
		})
		:find()
end

return telescope.register_extension({
	setup = function(optsExt, opts) end,
	exports = {
		issues = glab_issues,
	},
})
--glab_issues({ fields = { state = "opened" } })
