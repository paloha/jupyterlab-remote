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

**Prerequisites:**

1. Assumes a Debian-based remote server with `bash` and `screen`.
1. Make sure that `$PROJECT_DIR` folder exists on your remote.
1. Then make sure a Python virtualenv exists on `$VENV_PATH`.
1. And finally, make sure `jupyter-lab` is installed within the virtualenv.

**Installing:**

* copy the `remoteJupyter.sh` into `~/.bash_scripts`
* `chmod +x ~/.bash_scripts/remoteJupyter.sh`
* make an alias in `~/.bash_aliases`, e.g. `alias remoteJupyter=~/.bash_scripts/remoteJupyter.sh`
* open the `~/.bash_scripts/remoteJupyter.sh` and change the config within 

**Running:**

* Simply run using the chosen alias

**Uninstalling:**

* On remote: `rm ~/.jupyter/remoteJupyter_config.json` and `screen -XS jupyter_session quit`
* On local (Ubuntu): kill existing tunnel with `lsof -ti :$LOCAL_PORT | xargs -r kill -9`, naturally substitute the port
* On local (Ubuntu): `rm ~/.bash_scripts/remoteJupyter.sh` and remove the alias from `~/.bash_aliases` 

More info, notes, comments, etc. in the comments in the file itself.

## License

MIT