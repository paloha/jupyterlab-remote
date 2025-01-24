# JupyterLab remote

A hacky bash script that creates an SSH tunnel to a remote server then configures and runs jupyterlab server instance there and opens it locally in the web browser. Ideal to make your life easier when you are often working on a remote machine via Jupyter Lab.  

## What does it do?

* check if ssh tunnel exists, make it if not
* copy a config file of jupyter (allowing only password access) onto remote
* start a named screen session if not already running
* start the jupyter lab instance in the screen session
* open local browser window with jupytera lab running  
* inform the user about the progress & password in the terminal


## Quickstart

* copy the `remoteJupyter.sh` into `~/.bash_scripts`
* `chmod +x ~/.bash_scripts/remoteJupyter.sh`
* make an alias in `~/.bash_aliases`, e.g. `alias remoteJupyter=~/.bash_scripts/remoteJupyter.sh`
* run using the alias

More info, notes, comments, etc. in the comments in the file itself.

## License

MIT