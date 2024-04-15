#Usage: GET_SERVER_PORT_FROM_PROFILE <profile name>
#It's gonna read the server port from configuration file in the server folder, if it exists
function GET_SERVER_PORT_FROM_PROFILE () {
	if [ ! -f "$CONFIG_FILES_FOLDER/$1.profile" ];
	then
	    echo -e "${C_RED}Error (GET_SERVER_PORT_FROM_PROFILE)!${C_ESC}"
#	    echo -e "${C_CYAN}-${C_ESC}"
	else
		# Reads the server folder path from provided profile name
		local SERVER_FOLDER_PATH="$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$1.profile" SERVER_FOLDER)"
			# If it doesn't exist display "-----"
			if [ ! -f "$SERVER_FOLDER_PATH/server.properties" ];
			then
				echo "-----"
			else
				echo "$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER_PATH/server.properties" "server-port")"
			fi
	fi
}

#Get and color the server status
function COLORED_SERVER_STATUS () {
	if [ "$(CHECK_SERVER_STATUS $DEFAULT_SCREEN_SESSION_NAME-$1)" = "ONLINE" ]; then
		echo -e "${C_GREEN}online${C_ESC}"
	elif [ "$(CHECK_SERVER_STATUS $DEFAULT_SCREEN_SESSION_NAME-$1)" = "OFFLINE" ]; then
		echo -e "${C_DEFAULT}offline${C_ESC}"
	fi
}

#Prepare server slot with description
function PREPARE_SERVER_SLOT_DESC () {
	if [ ! -f "$CONFIG_FILES_FOLDER/$1.profile" ];
	then
	    echo -e "${C_BLUE}- empty slot -${C_ESC}"
	else
		echo -e "[server port: ${C_CYAN}$(GET_SERVER_PORT_FROM_PROFILE $1)${C_ESC}] [server status: $(COLORED_SERVER_STATUS $1)] [$(READ_PROFILE_ALIAS $1)]"
	fi
}

#Server slot picker main menu
function SERVER_PROFILE_PICKER () {
while :
do
	clear
	echo "Cubes launcher v$VERSION - Server profile picker"

	echo
	CUBES_WELCOME_MESSAGE

	DEBUG_MODE_DISPLAY

	echo
	echo "Server IP (local): $(GET_LOCAL_IP)"
	echo 
	echo "Select profile you want to manage and press [ENTER]."
	echo 
	echo -e "[1]   -  ${C_CYAN}profile 1${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server1)"
	echo -e "[2]   -  ${C_CYAN}profile 2${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server2)"
	echo -e "[3]   -  ${C_CYAN}profile 3${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server3)"
	echo -e "[4]   -  ${C_CYAN}profile 4${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server4)"
	echo -e "[5]   -  ${C_CYAN}profile 5${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server5)"
	echo -e "[6]   -  ${C_CYAN}profile 6${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server6)"
	echo -e "[7]   -  ${C_CYAN}profile 7${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server7)"
	echo -e "[8]   -  ${C_CYAN}profile 8${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server8)"
	echo -e "[9]   -  ${C_CYAN}profile 9${C_ESC}  $(PREPARE_SERVER_SLOT_DESC server9)"
	echo -e "[10]  -  ${C_CYAN}profile 10${C_ESC} $(PREPARE_SERVER_SLOT_DESC server10)"
	echo
	echo "[0] - Exit"
	echo
	echo -n "Type the number: "
	read SERVER_PICKER_MENU

	case $SERVER_PICKER_MENU in
		0)
		  END 0
		;;

		[1-9]|10)
				if [ ! -f "$CONFIG_FILES_FOLDER/server${SERVER_PICKER_MENU}.profile" ]; then
					clear
					echo "This profile doesn't exist, yet"
					echo "Press [ENTER] to make a new profile"
					PAUSE "Press [CTRL] + [C] to cancel and exit"
					MAKE_EMPTY_CONFIG_FILE_FROM_TEMPLATE server${SERVER_PICKER_MENU}
		   			SERVER_PROFILE_NAME="server${SERVER_PICKER_MENU}"
					nano "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile"
				else
					 echo "SERVER_PROFILE_NAME has been set to server1"
		   			SERVER_PROFILE_NAME="server${SERVER_PICKER_MENU}"
				fi
           break
		;;

		*) echo "Incorrect option"
		;;
	esac
done
}

#Screen session menu
function CUBES_SCREEN_SESSION_MENU {
#Here starts the loop of the main menu
#To break out of it, use "break"
while :
do
	clear
    echo "Cubes launcher v$VERSION - session manager"
    echo
	echo "Select the option and press [ENTER]."
	echo 
	echo "[1] - End the session"
	echo "[2] - Force the session to end"
	echo "[3] - Start the session (useless)"
	echo
	echo "[4] - Open a new terminal window with the screen session (works only if you use X server)"
	echo "[5] - Open the session here (use [CTRL]-[A] + [D] to go back)"
	echo
	echo "[0] - Go back"
	echo
	echo -n "Type the number: "
	read OPTION1

	case $OPTION1 in

		0)
		   break
		;;


		1)
			END_SCREEN_SESSION
		;;

		2) 
			KILL_SCREEN_SESSION
		;;

		3)
			START_SCREEN_SESSION
		;;

		4)
			x-terminal-emulator -e "bash -c 'screen -r $SCREEN_SESSION_NAME'"
		;;

		5)
			screen -r $SCREEN_SESSION_NAME
		;;

		*) echo "Incorrect option"
		;;
	esac
done
}

#Service menu
function SERVICE_MENU () {
while :
do

	clear
	echo "Cubes launcher v$VERSION - service menu"
	echo 
	echo "Select an option and press [ENTER]."
	echo 
	echo "[1] - Display version of used Java environment"
	echo
	echo "[2] - Make a backup of configuration files"
	echo
	echo "[3] - Open the configuration files viewer"
	echo
	echo -e "[4] - Reload current configuration profile (${C_CYAN}$SERVER_PROFILE_NAME.profile${C_ESC})"
	echo
	echo "[5] - Open current configuration file in default text editor (X server required)"
	echo "[6] - Open current configuration file in nano"
	echo
	echo "[0] - Go back"
	echo
	echo -n "Type the number: "
	read OPTION2

	case $OPTION2 in
		0)
		  break
		;;

		1)
			clear
			echo "Using: java -version"
				if [[ "$CUSTOM_JAVA_PATH_ENABLED" = "TRUE" ]]; then
					if [ -f "$CUSTOM_JAVA_PATH/java" ]; then
						echo "Custom path: $CUSTOM_JAVA_PATH"
						echo "--------------------"
						"$CUSTOM_JAVA_PATH/java" -version
					else
						echo "Error: Can't find java in specified path!"
					fi
				else
					echo "--------------------"
					java -version
				fi
			echo "--------------------"
			echo "Done."
			PAUSE "Press [ENTER] to go back to the main menu"
			break
		;;

		2) 
		   clear
		   MAKE_CONFIG_BACKUP
		   echo 
		   PAUSE "Press [ENTER] to go back to the main menu"
		   break
		;;

		3)
		  CUBES_CONFIG_VIEWER
		  echo
		  PAUSE "Press [ENTER] to continue"
		;;

		4)
			LOAD_CONFIGURATION
		  	break
		;;

		5)
			xdg-open "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile"
		;;

		6)
			nano "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile"
		;;

		*) echo "Incorrect option"
		;;
	esac
done
}

#Reads and shows values from world configuration file
function DISPLAY_WORLD_SETTINGS () {
	echo "Cubes launcher v$VERSION - server world configuration viewer"
	echo
	echo -e "Max amount of players: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "max-players")${C_ESC}"
	echo -e "Game mode: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "gamemode")${C_ESC}"
	echo -e "Difficulty: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "difficulty")${C_ESC}"
	echo -e "Hardcore mode: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "hardcore")${C_ESC}"
	echo -e "Forced gamemode: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "force-gamemode")${C_ESC}"
	echo -e "Allow flight: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "allow-flight")${C_ESC}"
	echo -e "Command blocks enabled: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "enable-command-block")${C_ESC}"
	echo
	echo -e "Level seed: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "level-seed")${C_ESC}"
	echo -e "View distance (chunks): ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "view-distance")${C_ESC}"
	echo
	echo -e "Is PVP enabled? (true or false): ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "pvp")${C_ESC}"
	echo -e "NPCs spawn: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "spawn-npcs")${C_ESC}"
	echo -e "Animals spawn: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "spawn-animals")${C_ESC}"
	echo -e "Monsters spawn: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "spawn-monsters")${C_ESC}"
	echo
	echo -e "Online mode: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "online-mode")${C_ESC}"
	echo -e "White list enabled: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "white-list")${C_ESC}"
	echo -e "White list enforced: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$SERVER_FOLDER/server.properties" "enforce-whitelist")${C_ESC}"

}

#Server commands menu
# Usage if embedded:
# SERVER_COMMANDS_MENU SHORTCUT <option in the menu>
function SERVER_COMMANDS_MENU () {

#Here starts the loop of the main menu
#To break out of it, use "break"
while :
do
	clear
    echo "Cubes launcher v$VERSION - server commands menu"
    echo
	echo "Select an option and press [ENTER]."
	echo 
	echo "[1] - Manual save"
	echo
	echo "[2] - Stop the server"
	echo "[3] - Stop the server with 15 seconds delay"
	echo
	echo "[4] - Send a message (as the server)"
	echo
	echo "[5] - Your own command (as the server)"
	echo
	echo "[0] - Go back"
	echo
	echo -n "Type the number: "

	if [[ "$1" = "SHORTCUT" ]];
		then
			OPTION1="$2"
		else
			read OPTION1
	fi

	case $OPTION1 in

		0)
		   break
		;;


		1)
		   clear
		   echo "Launcher: Saving the world..."
		   SEND_COMMAND /say Saving the world...
		   SEND_COMMAND /say The server might lag a bit!
		   SEND_COMMAND /save-all
		   SEND_COMMAND /say Saved!
			PAUSE "Done. Press [ENTER] to continue"
			
				if [[ "$1" = "SHORTCUT" ]]; then
					break
				fi
		;;

		2)
		   clear
		   echo "Stopping the server..."
		   SEND_COMMAND stop
			PAUSE "Done. Press [ENTER] to continue"

				if [[ "$1" = "SHORTCUT" ]]; then
					break
				fi
		;;

		3) 
		   clear
		   echo "Stopping the server after 15 seconds..."
		   echo "This can be cancelled with [CTRL] + [C]"
		   SEND_COMMAND /say Warning!
		   SEND_COMMAND /say The server will be turned off in 15 seconds!
		   echo "Wait 15 seconds..."
		   sleep 15
		   SEND_COMMAND stop
			PAUSE "Done. Press [ENTER] to continue"
				
				if [[ "$1" = "SHORTCUT" ]]; then
					break
				fi
		;;

		4)
		   clear
		   echo "Type the message and press [ENTER]."
		   read MESSAGE_TO_SERVER
		   SEND_COMMAND /say $MESSAGE_TO_SERVER
			PAUSE "Done. Press [ENTER] to continue"
				
				if [[ "$1" = "SHORTCUT" ]]; then
					break
				fi
		;;

		5)
		   clear
		   echo "Type your command and press [ENTER]."
		   read COMMAND_TO_SERVER
		   SEND_COMMAND $COMMAND_TO_SERVER
			PAUSE "Done. Press [ENTER] to continue"
				
				if [[ "$1" = "SHORTCUT" ]]; then
					break
				fi
		;;

		*) echo "Incorrect option"
		;;
	esac
done
}

#Function with menu for backup restoration
function RESTORE_BACKUP_MENU () {

	# Function to display informations from persistent_data file
	function DISPLAY_BACKUP_INFORMATIONS () {
			echo -e "${C_CYAN}Informations:${C_ESC}"
			echo -e "    ${C_CYAN}Profile name:   ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" PROFILE_NAME)"${C_ESC}
			echo -e "    ${C_CYAN}Alias:          ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" PROFILE_ALIAS)"${C_ESC}
			echo -e "    ${C_CYAN}Time of backup: ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" BACKUP_EXACT_DATE)"${C_ESC}
			echo -e "    ${C_CYAN}File path:      ${C_YELLOW}$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" LAST_BACKUP_FILE)"${C_ESC}
	}

echo "Checking persistent_data file..."
#if that file exists, try to read path to last backup file. if it exists sets a variable
if [ -f "$CONFIG_FILES_FOLDER/persistent_data" ]; then
	local LAST_BACKUP_PATH=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" LAST_BACKUP_FILE)
		# Suggest a path if it's available
		if [ -f "$LAST_BACKUP_PATH" ]; then
			local SUGGEST_PATH=TRUE
		fi
else
	# Not possible. Do not suggest the path
	local SUGGEST_PATH=FALSE
fi

# Menu 1
while :
do
	clear
	echo "Cubes launcher v$VERSION - restoring backup menu"
	echo

	if [ "$SUGGEST_PATH" = "TRUE" ]; then
		echo -e "${C_CYAN}Last backup has been found.${C_ESC}"
		echo
		DISPLAY_BACKUP_INFORMATIONS
	fi

	echo

	if [ "$SUGGEST_PATH" = "TRUE" ]; then
		echo "[1] - Use something else"
		echo "[2] - Use something else (GUI file picker)"
		echo -e "${C_CYAN}[3] - Use the previous backup${C_ESC}"
	else
		echo "[1] - Enter path to backup file"
		echo "[2] - Open GUI file picker"
	fi

	echo
	echo "[0] - Cancel"
	echo
	echo -n "Type the number: "
	read OPTION1

	case $OPTION1 in
		1) 
			local DONT_DISPLAY_THE_INFO=TRUE
			local LAST_BACKUP_PATH=
			local SUGGESTED_FILE_PATH=
			local SUGGEST_PATH=FALSE
			break
		;;

		2) 
			local DONT_DISPLAY_THE_INFO=TRUE
			local LAST_BACKUP_PATH=
			echo "Using Zenity for file picker"
			BACKUP_FILE_PATH=$(zenity --file-selection --title="Select the server backup file" --file-filter='7-Zip archive (.7z) | *.7z' --file-filter='All files | *')
			local SUGGESTED_FILE_PATH=$BACKUP_FILE_PATH
			local SUGGEST_PATH=FALSE
			break
		;;

		3) 
			if [ "$SUGGEST_PATH" = "TRUE" ]; then
				local DONT_DISPLAY_THE_INFO=FALSE
				local LAST_BACKUP_PATH=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/persistent_data" LAST_BACKUP_FILE)
				local SUGGESTED_FILE_PATH=$LAST_BACKUP_PATH
				break
			fi
		;;

		0)
			return 0
		;;

		*)
			echo "Incorrect option"
		;;
	esac
done

# Menu 2
while :
do
	clear
	echo "Cubes launcher v$VERSION - restoring backup menu"
	echo 
	echo -e "${C_CYAN}Before restoration Cubes will make another backup in case something goes wrong${C_ESC}"

	if [ "$SUGGEST_PATH" = "TRUE" ]; then
		echo 
		DISPLAY_BACKUP_INFORMATIONS
	fi
	echo
	echo
	echo "Press [ENTER] to confirm the file path"
	echo "Do not use brackets!"
	echo
	echo -e "Type ${C_CYAN}0${C_ESC} as path to go back or use [CTRL] + [C]"
	echo
	read -p "Path to backup file: " -i "$SUGGESTED_FILE_PATH" -e BACKUP_FILE_PATH

	if [ "$BACKUP_FILE_PATH" = "0" ]; then
		return 0
	fi

	clear

	# If file doesn't exists, stop
	if [ ! -f "$BACKUP_FILE_PATH" ]; then
		echo "Cubes launcher v$VERSION - restoring backup menu"
		echo 
		echo "Error"
		echo "File in the provided path doesn't exist!"
		echo 
		PAUSE "Press [ENTER] to continue"
		SUGGESTED_FILE_PATH=$BACKUP_FILE_PATH
	else
		clear
		echo "Making backup of current folder..."
			MAKE_BACKUP DO_NOT_SAVE_TO_PERSISTENT
		echo "Removing files from the server folder..."
			rm -rf "$SERVER_FOLDER/"*
		echo "Unpacking the archive..."
			echo "--------------------"
				7z x "$BACKUP_FILE_PATH" -o"$SERVER_FOLDER"
			echo "--------------------"
		
		PAUSE "Restored."
		break
	fi
done
}