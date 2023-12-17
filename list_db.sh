#!/bin/bash

data_folder="./database"

# Check if the "data" folder exists
if [ ! -d "$data_folder" ]; then
	echo "No databases yet. 'database' folder does not exist."
else
	echo "Already existing databases:"

	# List existing databases in the "data" folder
	if [ "$(ls -A "$data_folder")" ]; then
		ls -F "$data_folder" | grep / | tr / " "
		./main
	else
		echo "No databases yet. 'data' folder is empty."
	fi
fi

cd . &>/dev/null
