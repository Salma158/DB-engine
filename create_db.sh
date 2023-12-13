#!/bin/bash

data_folder="./data"

# Check if the "data" folder exists
if [ ! -d "$data_folder" ]; then
    mkdir "$data_folder"
    echo "Created 'data' folder."
fi

while true; do
    echo "Please enter a valid database name (without spaces or special characters):"
    IFS= read -r dbname

    case $dbname in
        '' )
            echo "Error: You entered an empty name. Please enter a proper name."
            continue;;
        ' '*)  # Check if the name starts with a space
            echo "Error: The name cannot start with a space."
            continue;;
        *' ' | ' '* | *' '* )
            echo "Error: The name cannot start, end, or contain spaces in between."
            continue;;
        [0-9]* )
            echo "Error: The name should not start with numbers."
            continue;;
        *[!a-zA-Z0-9_]* )
            echo "Error: The name should not contain special characters."
            continue;;
        * )
            # Check if the database already exists in the ./data folder
            dbpath="$data_folder/$dbname"
            if [ -n "$(find "$data_folder" -type d -name "$dbname" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
                echo "Error: Database '$dbname' already exists in $data_folder."
                echo "Existing databases:"
                ls -1 "$data_folder"
                continue
            else
                mkdir -p "$dbpath" && echo "Success: Database directory '$dbname' created."
                break
            fi
            ;;
    esac
done





