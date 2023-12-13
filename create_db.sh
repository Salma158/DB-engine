#!/bin/bash

while true
do
    echo "Please enter a valid database name (without spaces or special characters):"
    IFS= read -r dbname

    # Replace spaces with underscores
    dbname="${dbname// /_}"

    case $dbname in
        '' )
            echo "Error: You entered an empty name. Please enter a proper name."
            continue;;
        [0-9]* )
            echo "Error: The name should not start with numbers."
            continue;;
        *[!a-zA-Z0-9_]* )
            echo "Error: The name should not contain special characters."
            continue;;
        * )
            # Check if the database already exists in the ./data folder
            dbpath="./data/$dbname"
            if [ -e "$dbpath" ] && [ -d "$dbpath" ]; then
                echo "Error: Database '$dbname' already exists in ./data."
                echo "Existing databases:"
                ls -1 "./data"
                continue
            else
                mkdir -p "$dbpath" && echo "Success: Database directory '$dbname' created."
                break
            fi
            ;;
    esac
done




