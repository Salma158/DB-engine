#!/bin/bash

function row_meta() {
    colnum=$1
    coldata=$(sed -n "${colnum}p" "./database/$db/${table_name}_meta")
    colname=$(echo "$coldata" | cut -d: -f1)
    datatype=$(echo "$coldata" | cut -d: -f2)
    constraints=$(echo "$coldata" | cut -d: -f3-)
    # Initialize counter for AutoIncremented column
     counter=$(wc -l < "$DB/$table_name")

    if [[ "$constraints" == *"AutoIncremented"* ]]; then
        # If the column is AutoIncremented, use the counter value and increment it
        insert_data=$counter
        echo "Auto-incremented value for $colname: $insert_data"
        counter=$((counter+1))
    else
        while true; do
            echo "Enter the value of the $colname column. Note that the data type should be ($coldata)"
            read insert_data

            # Validation for null value in PK
            if [[ "$constraints" == *"pk"* ]] && [ -z "$insert_data" ]; then
                echo "Error: Primary key ($colname) cannot be null."
                continue
            fi

            # Validation for integer data type
            if [ "$datatype" == "integer" ]; then
                if [[ ! "$insert_data" =~ ^[0-9]+$ ]]; then
                    echo "Error: Invalid input for integer data type. Please enter a numeric value."
                    continue
                fi
            fi

            # Validation for varchar data type (allowing any characters)
            if [ "$datatype" == "varchar" ] && [ -z "$insert_data" ]; then
                # Check if "notNull" is a constraint
                if [[ "$constraints" == *"notNull"* ]]; then
                    echo "Error: Invalid input for varchar data type. Please enter a non-empty string."
                    continue
                fi
            fi

            # Store constraints in an array
            IFS=':' read -ra constraints_array <<< "$constraints"
            valid_input=true

            # Iterate through constraints for validation
            for constraint in "${constraints_array[@]}"; do
                case "$constraint" in
                    "pk")
                        # Logic for pk constraint (e.g., checking uniqueness within the column)
                        if grep -qw "$insert_data" <(echo "${pk_values[@]}"); then
                            echo "Error: The value '$insert_data' for the primary key ($colname) must be unique within the column."
                            valid_input=false
                            break
                        fi

                        if grep -qw "$insert_data" "$DB/$table_name"; then
                            echo "Error: The value '$insert_data' for the primary key ($colname) already exists in the table."
                            valid_input=false
                            break
                        fi
                        ;;
                    "notNull")
                        # Logic for notNull constraint
                        if [ -z "$insert_data" ]; then
                            echo "Error: Value cannot be null for notNull constraint."
                            valid_input=false
                            break
                        fi
                        ;;
                    "unique")
                        # Logic for unique constraint
                        if grep -qw "$insert_data" "$DB/$table_name"; then
                            echo "Error: The value '$insert_data' for the column ($colname) must be unique within the column."
                            valid_input=false
                            break
                        fi
                        ;;
                esac
            done

            if [ "$valid_input" == true ]; then
                echo "You entered a valid value: $insert_data"
                break
            else
                echo "Please enter another unique value for the primary key ($colname)."
            fi
        done
    fi

    # Add the inserted value to arrays
    if [[ "$constraints" == *"pk"* ]]; then
        pk_values+=(" $insert_data ")
    fi

    # Append values into the table file
    echo -n "$insert_data " >> "$DB/$table_name"
}



echo "Please enter db_name"
read db
DB="./database/$db"

if [ -d "$DB" ]; then
    echo "Please enter table name"
    read table_name

    if [ -z "$table_name" ]; then
        echo "You entered an empty name."
    else
        if [ -f "$DB/$table_name" ] && [ -f "$DB/${table_name}_meta" ]; then
            echo "Now you are connected to the table: $DB/$table_name"
            numofcol=$(cat "${DB}/${table_name}_meta" | grep -v '^$' | wc -l)

            # Array to store the column names
            colnames=()

            # Arrays to store primary key and unique values
            declare -a pk_values
            declare -A column_values

            # Check if the file is empty before appending column names
            if [ ! -s "$DB/$table_name" ]; then
                echo -e "id\tage\tphone" >> "$DB/$table_name"
            fi

            for ((i=1; i<=numofcol; i++)); do
                row_meta "$i"
                colnames+=("$colname")
            done

            # Append a new line for the next row
            echo "" >> "$DB/$table_name"

            # Display row values
            echo "Row values:"
            echo "--------------------------------------------------"
            cat "$DB/$table_name" | column -t -o "  |  "
            echo "--------------------------------------------------"

            echo "Row created SUCCESSFULLY"
        else
            echo "Error: Table file or metadata not found."
        fi
    fi
else
    echo "Error: Database directory not found."
fi



