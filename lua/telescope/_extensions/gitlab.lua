local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error "This plugins requires nvim-telescope/telescope.nvim"
end

local has_glab = vim.fn.executable "glab" == 1
if not has_glab then
  error "This plugin requires the glab binary"
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local utils = require "telescope.utils"

local glab_command = function(args, opts)
  opts = opts or {}

  opts.verb = opts.verb or "GET"

  local _args = { "glab", "api", "--paginate" }
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

  if not opts.fields then
    opts.fields = {}
  end
  if opts.assignee then
    opts.fields.assignee_username = opts.assignee
  end
  if opts.author then
    opts.fields.author_username = opts.author
  end
  if opts.scope then
    opts.fields.scope = opts.scope
  end
  if opts.state then
    opts.fields.state = opts.state
  end
  print(vim.inspect(opts))
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
      finder = finders.new_table {
        results = issues,
        entry_maker = function(entry)
          content = string.format("%-42s|%s|%s", entry.references.full, entry.funny_state, entry.title)
          return {
            value = entry,
            display = content,
            ordinal = content,
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          utils.get_os_command_output { "open", selection.value.web_url }
        end)
        local run_command = function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.api.nvim_put(
            { string.format("(%s)[%s]", selection.value.references.full, selection.value.web_url) },
            "c",
            true,
            true
          )
        end

        map("n", "p", run_command)
        return true
      end,
      previewer = previewers.new_buffer_previewer {
        title = "gitlab issue preview",
        define_preview = function(self, entry, status)
          content_table = {}
          table.insert(content_table, string.format("Title     : %s", entry.value.title))
          table.insert(content_table, string.format("URL       : %s", entry.value.web_url))
          table.insert(content_table, string.format("Severity  : %s", entry.value.severity))
          for _, v in ipairs(entry.value.assignees) do
            table.insert(content_table, string.format("Assignee  : %s (%s)", v.name, v.username))
          end
          for _, v in ipairs(entry.value.labels) do
            table.insert(content_table, string.format("Label     : %s", v))
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content_table)
        end,
      },
    })
    :find()
end

return telescope.register_extension {
  setup = function(optsExt, opts) end,
  exports = {
    issues = glab_issues,
  },
}
