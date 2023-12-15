#!/bin/bash

function row_meta() {
    colnum=$1
    coldata=$(sed -n "${colnum}p" "./database/$db/${table_name}_meta")
    colname=$(echo "$coldata" | cut -d: -f1)
    datatype=$(echo "$coldata" | cut -d: -f2)
    constraints=$(echo "$coldata" | cut -d: -f3-)

    if [[ "$constraints" == *"AutoIncremented"* ]]; then
        # If the column is AutoIncremented, use the counter value
        insert_data=$2
        echo "Auto-incremented value for $colname: $insert_data"
    else
        while true; do
            echo "Enter the value of the $colname column. Note that the data type should be ($coldata)"
            read insert_data

            # Replace empty input with "_"
            if [ -z "$insert_data" ] && [[ "$constraints" != *"notNull"* && "$constraints" != *"pk"* ]]; then
                insert_data="_"
                break
            fi

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

            #
            # Iterate through constraints for validation
            for constraint in "${constraints_array[@]}"; do
                case "$constraint" in
                    "pk")
                        # Logic for pk constraint (e.g., checking uniqueness within the column)
                        if grep -qw "$insert_data" <(echo "${pk_values["$colname"]}"); then
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
        pk_values["$colname"]=$insert_data
    fi

    # Store column name and value in arrays
    column_values["$colname"]=$insert_data
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

            # Arrays to store primary key and all column values
            declare -A pk_values
            declare -A column_values

            # Check if the file is empty before appending column names
            if [ ! -s "$DB/$table_name" ]; then
                # If the file is empty, add column names
                for ((i=1; i<=numofcol; i++)); do
                    coldata=$(sed -n "${i}p" "./database/$db/${table_name}_meta")
                    colname=$(echo "$coldata" | cut -d: -f1)
                    echo -n "$colname" >> "$DB/$table_name"
                done
                echo "" >> "$DB/$table_name"
            fi

            # Initialize counter for AutoIncremented column
            counter=$(wc -l < "$DB/$table_name")

            for ((i=1; i<=numofcol; i++)); do
                row_meta "$i" "$counter"
            done

            # Append values into the table file
            for ((i=1; i<=numofcol; i++)); do
                colname=$(sed -n "${i}p" "./database/$db/${table_name}_meta" | cut -d: -f1)
                echo -n "${column_values["$colname"]} " >> "$DB/$table_name"
            done
            echo "" >> "$DB/$table_name"

            # Display row values
            echo "Row values:"
            echo "--------------------------------------------------"
            while IFS= read -r line; do
                echo "$line" | tr ',' ' ' | column -t -o "  |  "
            done < "$DB/$table_name"
            echo "--------------------------------------------------"

            echo "Row created SUCCESSFULLY"
        else
            echo "Error: Table file or metadata not found."
        fi
    fi
else
    echo "Error: Database directory not found."
fi




















