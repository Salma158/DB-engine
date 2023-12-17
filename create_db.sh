#!/bin/bash

data_folder="./database"

# Check if the "data" folder exists
if [ ! -d "$data_folder" ]; then
	mkdir "$data_folder"
	echo "Created 'database' folder."
fi

while true; do
	echo "Please enter a valid database name (without spaces or special characters):"
	read -r dbname

	# Check if the name is empty
	if [ -z "$dbname" ]; then
		echo "Error: You entered an empty name. Please enter a proper name."
		continue
	fi

	# Check if the name starts with or contains spaces
	if [[ $dbname == *' ' || $dbname == *' '* ]]; then
		echo "Warning: Spaces in the name have been replaced with underscores."
		dbname=$(echo "$dbname" | tr ' ' '_') # Replace spaces with underscores
		echo "New name: $dbname"
	fi

	# Check if the name starts with numbers
	if [[ $dbname == [0-9]* ]]; then
		echo "Error: The name should not start with numbers."
		continue
	fi

	# Check if the name contains special characters
	if [[ $dbname == *[!a-zA-Z0-9_]* ]]; then
		echo "Error: The name should not contain special characters."
		continue
	fi

	# Check if the database already exists in the ./data folder
	dbpath="$data_folder/$dbname"
	if [ -n "$(find "$data_folder" -type d -name "$dbname" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
		echo "Error: Database '$dbname' already exists in $data_folder."
		echo "Existing databases:"
		ls -1 "$data_folder"
		continue
	else
		mkdir -p "$dbpath" && echo "Success: Database directory '$dbname' created."
		./main
		break
	fi
done
