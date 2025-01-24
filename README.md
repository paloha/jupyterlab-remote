# JupyterLab remote

![Image](https://github.com/user-attachments/assets/228fe435-937c-43bc-bfd0-758d5f5d3fa6)

A bash script that creates an SSH tunnel to a remote server then configures and runs jupyterlab server instance there and opens it locally in the web browser. Ideal to make your life easier when you are often working on a remote machine via Jupyter Lab. 

Works on Ubuntu & Mac with a Debian-based remote server. Should also work on Windows, but it is less tested there.  

## What does it do?

* check if ssh tunnel exists, make it if not
* copy a config file of jupyter (allowing only password access) onto remote
* start a named screen session if not already running
* start the jupyter lab instance in the screen session
* open local browser window with jupytera lab running  
* inform the user about the progress & password in the terminal


## Quickstart

**Prerequisites:**

1. (Only for Windows): make sure Git is installed so you can utilize Git bash as a terminal.  
1. Assumes a Debian-based remote server with `bash` and `screen`.
1. Make sure that `$PROJECT_DIR` folder exists on your remote.
1. Then make sure a Python virtualenv exists on `$VENV_PATH`.
1. And finally, make sure `jupyter-lab` is installed within the virtualenv.

**Installing:**

* (Only for Windows): use Git bash as your terminal for all following.
* copy the `remoteJupyter.sh` into `~/.bash_scripts`
* (Only on Linux/Mac): `chmod +x ~/.bash_scripts/remoteJupyter.sh`
* (Only on Linux/Mac): make an alias in `~/.bash_aliases`, e.g. `alias remoteJupyter=~/.bash_scripts/remoteJupyter.sh`
* (Only on Linux/Mac): source the `~/.bash_aliases` or otherwise make the alias available in your terminal (based on your OS)
* open the `~/.bash_scripts/remoteJupyter.sh` and change the config within

**Running:**

* Simply run using the chosen alias
* (Only for Windows): instead of the bash alias, you can use a standard desktop shortcut to that script

**Uninstalling:**

* On remote: `rm ~/.jupyter/remoteJupyter_config.json` and `screen -XS jupyter_session quit`
* On local (Ubuntu): kill existing tunnel with `lsof -ti :$LOCAL_PORT | xargs -r kill -9`, naturally substitute the port
* On local (Ubuntu): `rm ~/.bash_scripts/remoteJupyter.sh` and remove the alias from `~/.bash_aliases` 

More info, notes, comments, etc. in the comments in the file itself.

## License

MIT