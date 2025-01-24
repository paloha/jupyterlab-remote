#!/bin/bash

##########################################################################################
# Author: Pavol Harar (pavol.harar@gmail.com)
# Date: 16. January 2025
# Tested on: Ubuntu 24.04 (local) | MacOSX (local) & Debian 12 (remote)
# Licence: MIT
# ASCII art done using https://patorjk.com/software/taag/
##########################################################################################
# NOTE 1: on HPC, the JupyterLab server port will be visible for all the users
# so choose a port that is unlikely to be occupied to prevent clashes, and 
# each user of this script should use a unique port & password. Otherwise
# other users could just connect to other people's jupyter labs and see their work.
##
# NOTE 2: In order to crate new password hashes, do:
# from jupyter_server.auth import passwd
# passwd()
##########################################################################################
# PREREQUISITES & INSTALLATION:
# On remote, create a python virtualenv in PROJECT_DIR and istall jupyter-lab in it
# On local:
# * copy this script to `~/.bash_scripts`
# * add `alias jupyterhub="~/.bash_scripts/jupyterhub.sh"` into `~/.bash_aliases`
# * configure the variables below
# * restat the terminal or `source ~/.bash_aliases`
# * and simply run `jupyterhub`
# * in your browser window, jupyter lab environment appears
# * to stop it, click `File > Shut Down`
##########################################################################################
# UNINSTALLATION & CLEANUP:
# On remote, `rm ~/.jupyter/myJupyterHub_config.json` and `screen -XS jupyter_session quit`
# On local, `rm ~/.bash_scripts/jupyterhub.sh` and remove the alias from `~/.bash_aliases`
# On local, kill existing tunnel with `lsof -ti :$LOCAL_PORT | xargs -r kill -9`
##########################################################################################
# CONFIGURATION (Make sure to do CLEANUP before reconfiguring)
SERVER="servername"  # assumes user&host configured in ~/.ssh/config
PROJECT_DIR="~/Jupyter"
VENV_PATH=".venv"  # relative to ~/PROJECT_DIR
SCREEN_NAME="jupyter_session"  # named screen session prevents spawning many virtual terminals
JUPYTER_CONFIG_FILE="~/.jupyter/myJupyterHub_config.json"  # Setting up password protection
LOCAL_PORT=8765  # Do not use 8888 to prevent clashes with local jupyter server
JUPYTER_PORT=20000  # Do not use 8888 to prevent with possibly already running jupyter server
JUPYTER_PASSWORD='put_your_pass_here' # If you change this, the hash below needs to be recomputed
JUPYTER_PASSWORD_HASH='argon2:$argon2id$v=compute_hash_of_your_password_using_python'
##########################################################################################




clear
echo -e "
 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  ░░░░░░░░░░░░░░░░░░░░░░░
 ░░      ░  ░░  ░     ░░  ░░  ░      ░     ░      ░░  ░░  ░░░░      ░     ░░░
 ▒▒▒▒▒▒  ▒  ▒▒  ▒  ▒▒  ▒  ▒▒  ▒▒▒  ▒▒▒  ▒▒▒▒  ▒▒  ▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒  ▒▒  ▒▒
 ▓▓▓▓▓▓  ▓  ▓▓  ▓     ▓▓▓    ▓▓▓▓  ▓▓▓    ▓▓      ▓▓  ▓▓  ▓▓▓▓      ▓     ▓▓▓
 ██  ██  █  ██  █  ███████  █████  ███  ████  █  ███  ██  ████  ██  █  ██  ██
 ███    ███    ██  ███████  █████  ███     █  ██  ██  ██     █  ██  █     ███
 ███████████████████████████████████████████████████  ███████████████████████

 ┌──────────────────────────────────────────────────────────────────────────┐
 │                                                                          │
 │      Helping you run your own JupyterLab on ISTA HPC since 01/2025       │
 │                                                                          │
 └──────────────────────────────────────────────────────────────────────────┘
"

# Function to start JupyterLab in a screen session
start_jupyter() {
    echo " ⏳ Configuring the server..."
    ssh -T "$SERVER" > /dev/null << EOF
        # Silence output except for your messages
        exec > /dev/null 2>&1

        # Ensure the Jupyter Server configuration directory exists
        mkdir -p ~/.jupyter/

        # Create or update the configuration file with the hashed password
        cat > ~/.jupyter/myJupyterHub_config.json << 'CONFIG'
{
    "ServerApp": {
        "jpserver_extensions": {
            "jupyterlab": true
        }
    },

    "IdentityProvider": {
        "token": ""
    },

    "PasswordIdentityProvider": {
        "hashed_password": "$JUPYTER_PASSWORD_HASH"
    }
}
CONFIG

        # Check if the screen session exists, if not create it
        if ! screen -list | grep -q "$SCREEN_NAME"; then
            screen -dmS "$SCREEN_NAME"
        fi

        # Run commands inside the screen session
        screen -S "$SCREEN_NAME" -X stuff "cd $PROJECT_DIR && source $VENV_PATH/bin/activate && jupyter-lab --no-browser --port=$JUPYTER_PORT --config=$JUPYTER_CONFIG_FILE \n"

EOF
}


# Check if the SSH tunnel exists and works
if ! echo "ping" | nc -w 2 localhost $LOCAL_PORT >/dev/null 2>&1; then
    echo " ⏳ Starting the SSH tunnel..."
    # Kill any existing tunnel on the port
    lsof -ti :$LOCAL_PORT | xargs -r kill -9
    # Recreate the tunnel
    ssh -fN -L localhost:$LOCAL_PORT:localhost:$JUPYTER_PORT "$SERVER" || ( echo -e " ❌ SSH tunnel could not be started. Check configuration." && exit 1 )
fi
echo -e " ✅ SSH tunnel active"

# Check if JupyterLab is already running and start it if it is not
if ! curl -s -m 10 localhost:$LOCAL_PORT >/dev/null; then
    # echo "  Remote JupyterLab is not running. Starting it on the server..."
    start_jupyter
    sleep 3
fi

# Verify if JupyterLab is accessible
if curl -s -m 10 localhost:$LOCAL_PORT >/dev/null; then
    echo -e " ✅ JupyterLab active at http://localhost:$LOCAL_PORT"
    echo -e " 🔑 Log in using password: $JUPYTER_PASSWORD \n"
    echo -e " 🏁 When you are done, click File > Shut Down \n"
    # Handling Ubuntu vs MAC differences
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "http://localhost:$LOCAL_PORT"
    else
        xdg-open "http://localhost:$LOCAL_PORT"
    fi
else
    echo -e " ❌ JupyterLab error. Please check your configuration. \n"
    echo "    Make sure ~/Jupyter/.venv with jupyter-lab installed exists on the server."
    echo "    Configuration can be done in $(realpath $0)"
fi