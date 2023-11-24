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

Telescope gitlab mrs

"Search for projects
Telescope gitlab repos

Telescope gitlab search
```

## Options

You can add more filter to issue in commands

```viml
" filter by state
Telescope gtlab issues state=opened<cr>
```

### Issue
[Issues API](https://docs.gitlab.com/ee/api/issues.html)
#### Options Filter
| Query    | filter                                  |
|----------|-----------------------------------------|
| author   | Filter by author                        |
| assignee | Filter by assignee                      |
| state    | Filter by state: {opened,closed}        |
| scope    | Filter by scope: {all}                  |
| fields   | Filter by passing all gitlab api fields |

#### Key mappings

| key     | Usage                               |
|---------|-------------------------------------|
| `<cr>`  | open web                            |
| `<c-p>` | insert a markdown-link to the issue |

### Merge Request
[Merge Requests API](https://docs.gitlab.com/ee/api/merge_requests.html)
#### Options Filter

| Query    | filter                                  |
|----------|-----------------------------------------|
| author   | Filter by author                        |
| reviewer | Filter by reviewer                      |
| state    | Filter by state: {opened,closed}        |
| scope    | Filter by scope: {all}                  |
| fields   | Filter by passing all gitlab api fields |
| labels   | Filter by labels                        |
| search   | Filter by text search                   |

#### Key mappings

| key     | Usage                               |
|---------|-------------------------------------|
| `<cr>`  | open web                            |

### Repo
[Projects API](https://docs.gitlab.com/ee/api/projects.html)
#### Options Filter
| Query    | filter                                  |
|----------|-----------------------------------------|
| search   | Filter by text search                   |
| fields   | Filter by passing all gitlab api fields |

#### Key mappings

| key     | Usage                               |
|---------|-------------------------------------|
| `<cr>`  | open web                            |
| `<c-p>` | insert a markdown-link to the issue |

### Search
[Search API](https://docs.gitlab.com/ee/api/search.html)
#### Options Filter

| Query  | filter                                  |
|--------|-----------------------------------------|
| author | Filter by author                        |
| scope  | Filter by scope: {blob,issues}          |
| query  | Filter by text search                   |
| fields | Filter by passing all gitlab ali fields |

#### Key mappings

| key     | Usage                               |
|---------|-------------------------------------|
| `<cr>`  | open web                            |
