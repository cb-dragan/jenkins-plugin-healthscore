# jenkins-plugin-healthscore
Obtains healthscores for a provided list of plugins

## Prerequirements

`plugins.txt` should contain a list of plugins, each plugin in a separate line.
The short names of the plugins should be used.

## Run
`get-scores.sh`

## Cache

When the webpage for a plugin is first downloaded, it is stored in `htmls/`.
When the script is run it checks if the plugin page is already in cache, and does not download it again if it is.

Todo: Cache invalidation if sufficient time has passed since last downloaded.

## Output

A CSV file is generated with scores for each plugin.  
