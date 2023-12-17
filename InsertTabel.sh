#!/usr/bin/bash

source validateDataType
source validateConstraint

function insert() {
	metaData=$(awk 'BEGIN {FS=":"} {print $0}' "./database/$1/${2}_meta")
	counter=1

	for x in $metaData; do
		colName=$(echo "$x" | cut -d ":" -f 1)
		dataType=$(echo "$x" | cut -d ":" -f 2)
		constraints=$(awk -F: -v target="$counter" '{if (NR == target) for (i=3; i<=NF; i++) {print $i}}' "./database/$1/${2}_meta")

		while true; do
			echo "insert data for column $colName "
			read value

			if [ -z "$value" ]; then
				value="_"
			fi

			isValidDataType $value $dataType
			DTvalid=$?

			if [[ $DTvalid -eq 1 ]]; then
				constraintValid=1
				if [[ $constraints != "" ]]; then
					for i in $constraints; do
						validateConstraints $counter $value $1 $2 $i
						constraintValid=$?
						if [[ $constraintValid -eq 0 ]]; then
							break
						fi
					done
				fi

				if [[ $constraintValid -eq 1 ]]; then
					if [[ $counter -eq 1 ]]; then
						echo -n "$value" >>"./database/$1/$2"
					else
						echo -n ":$value" >>"./database/$1/$2"
					fi
					break
				else
					echo "Invalid value: violates the constraints of the column"
					echo "Try again!"
				fi
			else
				echo "Invalid value data type: violates the data type of the column"
				echo "Try again!"
			fi
		done

		((counter++))
	done

	echo -e -n "\n" >>"./database/$1/$2"
	echo "sucessfully inserted data inside table"
	./main
}

while true; do
	

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
		./connectToDatabase
	elif [ -n "$(ls "$tables_folder" | grep -v "_meta$")" ]; then
		echo "Tables in the database '$database_name':"
		# List tables in the specified database, excluding files ending with "_meta"
		ls -F "$tables_folder" | grep -v / | grep -v "_meta$"
		echo "" # Add a new line for better formatting
	else
		echo "No tables found in the database '$database_name'."
		./connectToDatabase
		exit
	fi
	echo "What table do you want to insert into : "

	read name
	if [ -f ./database/$1/$name ]; then
		break
	else
		echo "there is not table with this name in the database !"
	fi
done

# Example usage:
insert $1 $name
