#!/bin/bash
#/--------------------------------------------------------------------------------------------------------|  www.vdm.io  |------/
#    __      __       _     _____                 _                                  _     __  __      _   _               _
#    \ \    / /      | |   |  __ \               | |                                | |   |  \/  |    | | | |             | |
#     \ \  / /_ _ ___| |_  | |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_  | \  / | ___| |_| |__   ___   __| |
#      \ \/ / _` / __| __| | |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __| | |\/| |/ _ \ __| '_ \ / _ \ / _` |
#       \  / (_| \__ \ |_  | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_  | |  | |  __/ |_| | | | (_) | (_| |
#        \/ \__,_|___/\__| |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__| |_|  |_|\___|\__|_| |_|\___/ \__,_|
#                                                        | |
#                                                        |_|
#/-------------------------------------------------------------------------------------------------------------------------------/
#
#	@author			Llewellyn van der Merwe <https://github.com/Llewellynvdm>
#	@copyright		Copyright (C) 2016. All Rights Reserved
#	@license		GNU/GPL Version 2 or later - http://www.gnu.org/licenses/gpl-2.0.html
#
#/-----------------------------------------------------------------------------------------------------------------------------/

# get script path
scriptPath="${BASH_SOURCE%/*}"
if [[ ! -d "$scriptPath" || "$scriptPath" == '.' ]]; then scriptPath="$PWD"; fi

# load notify
. "${scriptPath}/notify.sh"

# go to repositories directory
DIR="$HOME/VDM/REPOS"
if [ ! -d "$DIR" ] 
    then
    mkdir -p "$DIR"
fi

## setup forked repos to be able to sync with upstream
function setForkedRepos () {
    # ensure repos is already set
    cd "$DIR"
    if [ ! -d "$DIR/$1/$3" ] 
    then
	# ensure the github user folder is set
	if [ ! -d "$DIR/$1" ] 
	    then
	    mkdir -p "$DIR/$1"
	fi
	cd "$DIR/$1"
        # keep local repo small
        git clone --depth 3 "$2"
        cd "$DIR/$1/$3"
        # set upstream branch
        git remote add upstream "$4"

	# move back to script path
	cd "${scriptPath}"
	# also inform me
	notifyMe "Just added $1's $3 repo."
    fi
}

# array of repos
readarray -t REPOS < repos

for update in "${REPOS[@]}"; do
    repo=($update)
    setForkedRepos ${repo[0]} ${repo[1]} ${repo[2]} ${repo[3]}
done