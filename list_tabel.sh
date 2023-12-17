#!/bin/bash

database_name="$1"
data_folder="./database"

# Check if the specified database exists
if [ ! -d "$data_folder/$database_name" ]; then
	echo "Error: Database '$database_name' does not exist."
	exit 1
fi

# Check if there are tables in the specified database
tables_folder="$data_folder/$database_name"
if [ ! -d "$tables_folder" ] || [ -z "$(ls -A "$tables_folder")" ]; then
	echo "No tables found in the database '$database_name'."
elif [ -n "$(ls "$tables_folder" | grep -v "_meta$")" ]; then
	echo "Tables in the database '$database_name':"
	# List tables in the specified database, excluding files ending with "_meta"
	ls -F "$tables_folder" | grep -v / | grep -v "_meta$"
	echo "" # Add a new line for better formatting
else
	echo "No tables found in the database '$database_name'."
fi
./connectToDatabase
