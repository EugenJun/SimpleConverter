#!/usr/bin/env bash
set -euo pipefail

echo -e "Welcome to the Simple converter!"

function ask_option() {
    echo -e "\nSelect an option\n0. Type '0' or 'quit' to end program\n1. Convert units\n2. Add a definition\n3. Delete a definition"
    read -r user_option
}

function add_definition() {
    while :
    do
	echo "Enter a definition: "
	read -a user_definition
	re='^[a-z]+_to_[a-z]+ [-+]?[0-9]*\.?[0-9]+$'
        if [[ ${user_definition[@]} =~ $re && ${#user_definition[@]} -eq 2 ]]; then
            echo "${user_definition[@]}" >> "$1"
		break
        else
            echo "The definition is incorrect!"
        fi
    done
}

function delete_definition() {
    echo "Type the line number to delete or '0' to return"

    show_added_definitions $2

    while :
    do
    	read user_line
        if [ "$user_line" -eq 0 ];then
	    break
        elif [[ $user_line -gt 0 && $user_line -le $2 ]];then
	    sed -i "${user_line}d" "$1"
	    break
        else
	    echo "Enter a valid line number!"
	    continue
    	fi
    done
}

function show_added_definitions() {
    for i in $(seq "$1"); do
	echo "${i}. $(sed -n "${i}p" $file)";
    done
}

function convert_values() {

    echo "Type the line number to convert units or '0' to return"
    show_added_definitions $2

    while :
    do
    	read user_line2
        if [ "$user_line2" -eq 0 ];then
	    break
        elif [[ $user_line2 -gt 0 && $user_line2 -le $2 ]];then
	    echo "Enter a value to convert:"
	    while :
	    do
	        read user_value2
                if [[ $user_value2 =~ [-+]?[0-9]*\.?[0-9]+$ ]]; then
	            line=$(sed "${user_line2}!d" "$1")
	            read -a text <<< "$line"
		    result=$(echo "scale=2; ${text[1]} * $user_value2" | bc -l)
                    printf "Result: %s\n" "$result"
                    break
                else
		    echo "Enter a float or integer value!"
		    continue
	        fi
	    done
	    break
        else
	    echo "Enter a valid line number!"
	    continue
    	fi
    done

}

function has_definitions(){
    if [ ! -e "$file" ];then
	return 1
    elif [ "$(wc -w < $file)" -eq 0 ];then
        return 1
    else
	return 0
    fi
}

file="./definitions.txt"

while :
do
    ask_option
    case $user_option in
        0 | "quit")
	    echo -e "\nGoodbye!"
	    exit;;
	1)
	    if has_definitions; then convert_values $file "$(wc -l < $file)"; else echo "Please add a definition first!"; fi
	    continue;;
	2)
	    add_definition $file;;
	3)
            if has_definitions;then delete_definition $file "$(wc -l < $file)"; else echo "Please add a definition first!"; fi
	    continue;;
	*)
	    echo -e "\nInvalid option!\n"
	    continue;;
    esac
done
