## telescope-gitlab.nvim (WIP)

Gaze deeply into unknown gitlab issues using the power of telescope-gitlan.nvim.


### Installation

1. install gitlab cli (version 1.25.3 or greater)  [glab cli](https://docs.gitlab.com/ee/editor_extensions/gitlab_cli/#install-the-cli)
1. install [jq](https://stedolan.github.io/jq/download/)


#### Packer
```lua
use({
	"lrfurtado/telescope-gitlab.nvim",
	after = "telescope.nvim",
	config = function()
		require("telescope").load_extension("gitlab")
	end,
})
```
## Available commands
```viml
Telescope gitlab issues

"Using lua function
:lua require('telescope').extensions.gitlab.issues({fields={state="opened"}})<cr>

```

## Options

You can add more filter to issue in commands

```viml
" filter by state
Telescope gtlab issues state=opened<cr>
```

### Issue

#### Options Filter
[Detail](https://cli.github.com/manual/gh_issue_list)

| Query    | filter                               |
|----------|--------------------------------------|
| author   | Filter by author                     |
| assignee | Filter by assignee                   |
| state    | Filter by state: {opened,closed}     |
| scope    | Filter by scope: {all}               |

#### Key mappings

| key     | Usage                               |
|---------|-------------------------------------|
| `<cr>`  | open web                            |
| `<c-p>` | insert a markdown-link to the issue |
