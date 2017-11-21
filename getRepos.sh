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

# check and set arguments
errorNote=$'################################################################################################# \n'
errorNote+=$'#                                                                                               # \n'
errorNote+=$'#    Invalid argument please pass two argument                                                  # \n'
errorNote+=$'#    First the github username                                                                  # \n'
errorNote+=$'#    Second the local ssh HOST name set in the ssh config to push the updates                   # \n'
errorNote+=$'#                                                                                               # \n'
errorNote+=$'#################################################################################################'
if [ $# -eq 2 ] 
then
	# add the github user
	githubUser="$1"
	# add the local ssh user host name
	sshUser="$2"
else
	echo "$errorNote"
	exit 1
fi

# get script path
scriptPath="${BASH_SOURCE%/*}"
if [[ ! -d "$scriptPath" || "$scriptPath" == '.' ]]; then scriptPath="$PWD"; fi

# load notify
. "${scriptPath}/notify.sh"

# get first line with the github API key
sleutel=$(head -n 1 github)

startMessage="Getting $githubUser's repos and using $sshUser as the ssh HOST name"
echo $startMessage
# also inform me
notifyMe "${startMessage}"
# set the main length of all strings
mainlen="${#startMessage}"

# little echo tweak
function echoTweak () {
	echoMessage="$1"
	chrlen="${#echoMessage}"
	increaseBy=$((20+mainlen-chrlen))
	tweaked=$(repeat "$increaseBy")
	echo -n "$echoMessage$tweaked"
}

# little repeater
function repeat () {
	head -c $1 < /dev/zero | tr '\0' '\056'
}

# check if file exist
echoTweak "Getting list of excluded repos"
if [ ! -f "${scriptPath}/exclude" ] 
then
	excluded=(niksNi3 Ekweet BietjieLui)
	echo "NONE FOUND"
else
	# array of repos to exclude
	readarray -t excluded < "${scriptPath}/exclude"
	echo "DONE"
fi

# make sure the repos file is set
if [ ! -f "${scriptPath}/repos" ] 
then
	> "${scriptPath}/repos"
fi

# get all the user repos that are forked
echoTweak "Getting list of forked repos"
forks=$(curl -s -u "${sleutel}":x-oauth-basic "https://api.github.com/users/$githubUser/repos?type=forks")
echo "DONE"
# get only there full names
echoTweak "Loading repos full names"
fullnames=($( echo "$forks" | jq -r '.[].full_name'))
echo "DONE"
# get only names
echoTweak "Loading repos names"
names=($( echo "$forks" | jq -r '.[].name'))
echo "DONE"
# start the loop of this users forked repos
for nr in "${!fullnames[@]}"; do
	# check if we should add this repo
	echoTweak "Can ${names[$nr]} upstream be set"
	if [[ ! " ${excluded[@]} " =~ " ${names[$nr]} " ]];
	then
		# build repo A string
		repoFingerPrint="${githubUser} git@$sshUser:${fullnames[$nr]}.git ${names[$nr]} git@github.com:"
		# check if it is already in repos list
		if grep -q "$repoFingerPrint" repos; then
			# don't add again
			echo "ALREADY SET"
		else
			echo "YES"
			# now get the parent repo
			echoTweak "Getting ${names[$nr]}'s parent info...searching"
			repo=$(curl -s -u "${sleutel}":x-oauth-basic "https://api.github.com/repos/${fullnames[$nr]}")
			# get parent name
			parent=($( echo "$repo" | jq -r '.parent.full_name'))
			#add to file
			if [[ "null" != "$parent" ]]
			then
				echo "DONE"
				echoTweak "Adding ${names[$nr]}'s parent info to upstream repos list"
				# the branch file name
				branchFileName="${parent//\//.}"

				# get the branches (not needed for now)
	#			branches=$(wget -q -O- "https://api.github.com/repos/$parent/branches")
	#			branchesNames=($( echo "$branches" | jq -r '.[].name'))
	#			# add branches to local file
	#			> "branches/$branchFileName"
	#			for bnr in "${!branchesNames[@]}"; do
	#				echo "${branchesNames[$bnr]}" >> "branches/$branchFileName"
	#			done

				# save the data to the file
				echo "${repoFingerPrint}${parent}.git ${branchFileName}" >> "${scriptPath}/repos"
				echo "DONE"
				# also inform me
				notifyMe "Adding ${names[$nr]}'s parent info to upstream repos list"
			else
				echo "NO PARENT FOUND!"
			fi
		fi
	else
		echo "NO - EXCLUDED!"
	fi
done

echo "Getting all forked repos for $githubUser is now complete"

# also inform me
notifyMe "Getting all forked repos for $githubUser is now complete"