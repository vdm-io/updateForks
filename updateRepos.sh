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

# keep forked repos in sync with upstream
DIR="$HOME/VDM/REPOS"
cd "$DIR"
gitHubUsers=($(ls -d -- */))
for gitHubUser in "${gitHubUsers[@]}"; do
	cd "$DIR/$gitHubUser"
	echo "@ user:${gitHubUser}"
	repos=($(ls -d -- */))
	for folder in "${repos[@]}"; do
		cd "$DIR/$gitHubUser/$folder"
		echo "@ repo:${folder}"
		git fetch upstream
		onBranch=$(git symbolic-ref --short -q HEAD)
		git reset --hard upstream/"$onBranch"
		git clean -f -d
		echo "reset $onBranch to upstream/$onBranch"
		git push origin "$onBranch"
		echo "pushed to origin $onBranch"
		branches=($(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}'))
		echo "local branches are ${branches[@]}"
		for tak in "${branches[@]}"; do
		    if [[ "$tak" != "$onBranch" ]]
		    then
			git checkout "$tak"
			git reset --hard upstream/"$tak"
			git clean -f -d
			echo "reset $tak to upstream/$tak"
			git push origin "$tak"
			echo "pushed to origin $tak"
		    fi
		done
	done
	# move back to script path
	cd "${scriptPath}"
	notifyMe "Just finished update of ${gitHubUser} repos."
done