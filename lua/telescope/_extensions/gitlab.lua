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
local log = require "telescope.log"

local has_glab = vim.fn.executable "glab" == 1
if not has_glab then
  utils.notify("telescope-gitlab", {
    msg = "This plugin requires the glab binary",
    level = "ERROR",
  })
end

local has_jq = vim.fn.executable "jq" == 1
if not has_jq then
  utils.notify("telescope-gitlab", {
    msg = "This plugin requires the jq binary",
    level = "ERROR",
  })
end

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

  _args = vim.list_extend(_args, args)
  wrapped_cmd = { "/bin/sh", "-c", table.concat(_args, " ") .. "| jq -s 'map(to_entries) | flatten'" }
  return wrapped_cmd
end

local get_glab_command_json = function(args, opts)
  cmd = glab_command(args, opts)
  log.info("get_glab_command_json: ", table.concat(cmd, " "))
  return utils.get_os_command_output(cmd, opts.cwd, opts.timeout)
end

local glab_issues = function(opts)
  opts = opts or {}

  if not opts.fields then
    opts.fields = {}
  end

  if opts.search then
    opts.fields.search = opts.search
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
  output = get_glab_command_json({ "/issues" }, opts)

  o = vim.json.decode(table.concat(output, ""))
  issues = {}
  for _, v in ipairs(o) do
    if v.value.state == "closed" then
      state = "😀(closed)"
    else
      state = "💩(open)  "
    end
    v.value.funny_state = state
    table.insert(issues, v.value)
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

local glab_mrs = function(opts)
  opts = opts or {}

  if not opts.fields then
    opts.fields = {}
  end

  if opts.labels then
    opts.fields.labels = opts.labels
  end

  if opts.search then
    opts.fields.search = opts.search
  end

  if opts.reviewer then
    opts.fields.reviewer_username = opts.reviewer
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
  output = get_glab_command_json({ "/merge_requests" }, opts)

  o = vim.json.decode(table.concat(output, ""))
  mrs = {}
  for _, v in ipairs(o) do
    if v.value.state == "merged" then
      state = "✅ (merged)"
    else
      state = "💩(" .. v.value.state .. ")  "
    end
    v.value.funny_state = state
    table.insert(mrs, v.value)
  end

  pickers
    .new(opts, {
      prompt_title = "Glab Mrs",
      finder = finders.new_table {
        results = mrs,
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
    mrs = glab_mrs,
  },
}
