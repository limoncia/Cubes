#Backup function
#It packs entire folder from $SERVER_FOLDER variable
#Then it calculates SHA256 checksums and saves them
#Backup file name is "${SERVER_BACKUP_FILE_NAME}_XX-XX_XX-XX-XXXX.7z"
#SHA256 file name is "${SERVER_BACKUP_FILE_NAME}_XX-XX_XX-XX-XXXX.7z_sha256.txt"
#Then it checks if the files were successfully created
#..
#Use "DO_NOT_SAVE_TO_PERSISTENT" as an argument to not save information to persistent file
function MAKE_BACKUP () {
	BACKUP_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
	EASY_READABLE_BACKUP_TIME=$(date '+%Y.%m.%d at %H:%M:%S')

	echo "Checking directory..."
	if [ -d "$BACKUP_FOLDER/$BACKUP_TIME" ]; then
		clear
		echo "Looks like you already made a backup at this time ($BACKUP_TIME)."
		echo "Please try again"
		echo "This also might be a rare error. In that case please restart this program"
		return 1
	fi

	echo "Making the backup..."
	echo "Time: $EASY_READABLE_BACKUP_TIME"

	if [ "$1" = "DO_NOT_SAVE_TO_PERSISTENT" ]; then
		echo "No data will be saved to persistent_data file. 'DO_NOT_SAVE_TO_PERSISTENT' has been used."
	fi

	mkdir "$BACKUP_FOLDER/$BACKUP_TIME"
	echo "Using 7z"
	echo "--------------------"
		7z a -t7z -mx$COMPRESSION_MODE "$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" "$SERVER_FOLDER/*"
	echo "--------------------"

	echo "Calculating checksums (sha256)..."
	sha256sum "$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" | awk '{print $1}' > "$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z_sha256.txt"
	
	echo "Checking if the files were created successfully..."
		if [ ! -f "$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" ];
		then
			echo -e "${C_RED}(1\2) Warning! There was an error with writing the backup file!${C_ESC}"
		else
			echo -e "${C_GREEN}(1\2) The backup file has been saved successfully!${C_ESC}"

				# If 'DO_NOT_SAVE_TO_PERSISTENT' has NOT been used, save metadata to 'persistent_data' file
				if [ ! "$1" = "DO_NOT_SAVE_TO_PERSISTENT" ]; then
					echo "Saving information about this backup to 'persistent_data' file"
						echo "LAST_BACKUP_FILE=$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z">"$CONFIG_FILES_FOLDER/persistent_data"
						echo "PROFILE_NAME=$SERVER_PROFILE_NAME.profile">>"$CONFIG_FILES_FOLDER/persistent_data"
						echo "PROFILE_ALIAS=$(READ_PROFILE_ALIAS $SERVER_PROFILE_NAME)">>"$CONFIG_FILES_FOLDER/persistent_data"
						echo "BACKUP_EXACT_DATE=$EASY_READABLE_BACKUP_TIME">>"$CONFIG_FILES_FOLDER/persistent_data"
				fi

				# Saving extra info because this switch is used only if this backup is being made before restoring other one
				if [ "$1" = "DO_NOT_SAVE_TO_PERSISTENT" ]; then
					echo "This backup has been made before restoring of other one">"$BACKUP_FOLDER/$BACKUP_TIME/extra info.txt"
				fi
		fi

		if [ ! -f "$BACKUP_FOLDER/$BACKUP_TIME/${SERVER_BACKUP_FILE_NAME}_$BACKUP_TIME.7z_sha256.txt" ]; then
			echo -e "${C_RED}(2\2) Warning! There was an error with writing the checksum file!${C_ESC}"
		else
			echo -e "${C_GREEN}(2\2) The checksum file has been saved successfully!${C_ESC}"
		fi
}

# Makes folder for config files and places config template to be edited later by the user
# needs an argument to know to what file name it should be saved
function MAKE_EMPTY_CONFIG_FILE_FROM_TEMPLATE () {
mkdir "$CONFIG_FILES_FOLDER"
echo "# Cubes configuration script
# Format version 2.0

# Server alias
# Try to keep it short
SERVER_ALIAS=

# Server arguments the jar file will be launched with
# Example: -Xms3G -Xmx3G -XX:+UseG1GC
ARGUMENTS=

# Do you want to use custom Java path?
# Use TRUE or FALSE
CUSTOM_JAVA_PATH_ENABLED=FALSE

# Path to your custom Java version
CUSTOM_JAVA_PATH=

# Path to folder for backups
# Do not use quote marks
BACKUP_FOLDER=

# Path for this server directory
# Do not use quote marks
SERVER_FOLDER=

# Should the server GUI be used?
# Use TRUE or FALSE
# FALSE is recommended
SERVER_GUI=FALSE

# Name of the server jar file
SERVER_JAR_FILE=server.jar" > "$CONFIG_FILES_FOLDER/$1.profile"
}

# Displays local IP of the server
function GET_LOCAL_IP () {
	hostname -I | awk '{print $1}'
}

function CUBES_CONFIG_VIEWER () {
	clear
	echo "Cubes launcher v$VERSION - configuration files viewer"
	echo
	echo -e "BACKUP_FOLDER = ${C_YELLOW}$BACKUP_FOLDER${C_ESC}"
	echo -e "SERVER_FOLDER = ${C_YELLOW}$SERVER_FOLDER${C_ESC}"
	echo -e "SERVER_JAR_FILE = ${C_YELLOW}$SERVER_JAR_FILE${C_ESC}"
	echo -e "ARGUMENTS = ${C_YELLOW}$ARGUMENTS${C_ESC}"
	echo -e "SERVER_GUI = ${C_YELLOW}$SERVER_GUI${C_ESC}"
	echo -e "SERVER_ALIAS = ${C_YELLOW}$SERVER_ALIAS${C_ESC}"
	echo -e "CUSTOM_JAVA_PATH_ENABLED = ${C_YELLOW}$CUSTOM_JAVA_PATH_ENABLED${C_ESC}"
	echo -e "CUSTOM_JAVA_PATH = ${C_YELLOW}$CUSTOM_JAVA_PATH${C_ESC}"
	#echo -e "AUTO_BACKUP_MODE = ${C_YELLOW}$AUTO_BACKUP_MODE${C_ESC}"
}

#Start the server
function START_THE_SERVER {
		clear
		echo "Starting the screen session..."
				START_SCREEN_SESSION
		echo "Launcher: Starting: java $ARGUMENTS -jar $SERVER_JAR_FILE $SERVER_GUI_USAGE"
		echo "----------"
		 	SEND_COMMAND "cd \"$SERVER_FOLDER\""
				if [[ "$CUSTOM_JAVA_PATH_ENABLED" = "TRUE" ]]; then
					SEND_COMMAND \"$CUSTOM_JAVA_PATH/java\" $ARGUMENTS -jar $SERVER_JAR_FILE $SERVER_GUI_USAGE
				else
					SEND_COMMAND java $ARGUMENTS -jar $SERVER_JAR_FILE $SERVER_GUI_USAGE
				fi
		PAUSE "The server started. Press [ENTER] to go back to the main menu to manage it."
}

#Function of making backups of configuration files
function MAKE_CONFIG_BACKUP () {
	BACKUP_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

	echo "Checking directory..."
	if [ -d "$BACKUP_FOLDER/$BACKUP_TIME config" ]; then
		clear
		echo "Looks like you already made a backup at this time ($BACKUP_TIME)."
		echo "Please try again"
		return 1
	fi

	echo "Making backup of configuration files..."
	echo "Time: $EASY_READABLE_BACKUP_TIME"
	mkdir "$BACKUP_FOLDER/$BACKUP_TIME config"

	echo "Using 7z"
	echo "--------------------"
	7z a -t7z -mx$COMPRESSION_MODE "$BACKUP_FOLDER/$BACKUP_TIME config/${SERVER_CONFIGURATION_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" "$CONFIG_FILES_FOLDER/*"
	echo "--------------------"

	echo "Calculating checksums (sha256)..."
	sha256sum "$BACKUP_FOLDER/$BACKUP_TIME config/${SERVER_CONFIGURATION_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" | awk '{print $1}' > "$BACKUP_FOLDER/$BACKUP_TIME config/${SERVER_CONFIGURATION_BACKUP_FILE_NAME}_$BACKUP_TIME.7z_sha256.txt"
	
	echo "Checking if the files were created successfully..."
		if [ ! -f "$BACKUP_FOLDER/$BACKUP_TIME config/${SERVER_CONFIGURATION_BACKUP_FILE_NAME}_$BACKUP_TIME.7z" ];
		then
		echo -e "${C_RED}(1\2) Warning! There was an error with writing the configuration backup file!${C_ESC}"
		else
		echo -e "${C_GREEN}(1\2) The configuration backup file has been saved successfully!"
		fi

		if [ ! -f "$BACKUP_FOLDER/$BACKUP_TIME config/${SERVER_CONFIGURATION_BACKUP_FILE_NAME}_$BACKUP_TIME.7z_sha256.txt" ];
		then
		echo -e "${C_RED}(2\2) Warning! There was an error with writing the checksum of configuration backup file!${C_ESC}"
		else
		echo -e "${C_GREEN}(2\2) The checksum of configuration backup file has been saved successfully!${C_ESC}"
		fi
}

#Start the screen session
function START_SCREEN_SESSION {
	screen -dmS "$SCREEN_SESSION_NAME"
}

#Function for sending commands to the screen session
#Usage: SEND_COMMAND <command> <command with spaces, etc.>
function SEND_COMMAND {
	screen -S "$SCREEN_SESSION_NAME" -p 0 -X stuff "$*$(printf \\r)"
	echo -e "Sent command: ${C_CYAN}$*${C_ESC}"
}

#Force the screen session to end
function KILL_SCREEN_SESSION {
	screen -X -S "$SCREEN_SESSION_NAME" quit
}

#End the screen session
function END_SCREEN_SESSION {
#	screen -S "$SCREEN_SESSION_NAME" -X stuff $'\003'  # Sends [CTRL]+[C]
	screen -S "$SCREEN_SESSION_NAME" -p 0 -X stuff "exit$(printf \\r)"
}

#Check current status of the server
#It will output either ONLINE or OFFLINE
#Usage: CHECK_SERVER_STATUS <screen session name>
function CHECK_SERVER_STATUS () {
    if screen -ls | grep -q "$1"; then
		echo "ONLINE"
    else
		echo "OFFLINE"
    fi
}

#Function of pause
#Usage:
#pause <text>
function PAUSE () {
	read -p "$*"
}

#Ends work of Cubes
#Usage : END <error code>
function END () {
	echo "----------"
	echo "End"
	exit "$1"
}

#Function that checks if the package is installed
#if it's not, it shows a warning
#Usage:
#CHECK_IF_PACKAGE_IS_INSTALLED <package name>
function CHECK_IF_PACKAGE_IS_INSTALLED () {
	if [ $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	echo -e "${C_RED}Warning! The '"$1"' package is not installed in the system!${C_ESC}"
	fi
}

function CUBES_WELCOME_MESSAGE () {
	echo "Configuration files location: $CONFIG_FILES_FOLDER"
#	echo -e "Use '${C_YELLOW}cubes -h${C_ESC}' or '${C_YELLOW}cubes --help${C_ESC}' to display the help page"
}

# Usage: READ_CONFIG "/location/to/config.file" value
# it will return the value
function READ_FROM_CONFIG_FILE () {
	if [ -f "$1" ];
	then
	    echo $(grep -E "^$2=" "$1" | awk -F '=' '{print $2}')
	else
	    echo -e "${C_RED}There was an error with reading configuration file${C_ESC}"
	fi
}

# Usage: READ_PROFILE_ALIAS <profile number>
# If it's too long (more than 100 characters) it will be cut at the end
function READ_PROFILE_ALIAS () {
	READ_PROFILE_ALIAS=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$1.profile" SERVER_ALIAS | cut -c 1-100)
	if [ -z "$READ_PROFILE_ALIAS" ]; then
		echo -e "${C_YELLOW}(no alias)${C_ESC}"
	else
		echo "$READ_PROFILE_ALIAS"
	fi
}

#Function to check how big is the specified directory. It shows rounded values in MB
#Usage: CHECK_DIRECTORY_SIZE <path to folder>
function CHECK_DIRECTORY_SIZE () {
	du -sm "$*" | cut -f1
}

#This loads the configuration files
function LOAD_CONFIGURATION () {
	#Server alias
	SERVER_ALIAS=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" SERVER_ALIAS)

	#Backup folder location
	BACKUP_FOLDER=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" BACKUP_FOLDER)

	#Server files location (folder where the JAR file is supposed to be)
	SERVER_FOLDER=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" SERVER_FOLDER)

	#Server JAR file
	SERVER_JAR_FILE=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" SERVER_JAR_FILE)

	#Arguments to start the JAR file with
	ARGUMENTS=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" ARGUMENTS)

	#Should the server GUI be turned on?
	SERVER_GUI=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" SERVER_GUI)
		if [ "$SERVER_GUI" = "TRUE" ]; then
			SERVER_GUI_USAGE=""
		elif [ "$SERVER_GUI" = "FALSE" ]; then
			SERVER_GUI_USAGE="nogui"
		else
			SERVER_GUI_USAGE="nogui"
		fi

	#Should the custom Java path be used?
	CUSTOM_JAVA_PATH_ENABLED=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" CUSTOM_JAVA_PATH_ENABLED)
		if [ ! "$CUSTOM_JAVA_PATH_ENABLED" = "TRUE" ]; then
			CUSTOM_JAVA_PATH_ENABLED="FALSE"
		fi

	#Path to custom Java environment (where the java executable is located)
	CUSTOM_JAVA_PATH=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" CUSTOM_JAVA_PATH)

	#Should backup be made every time after the server ends its work?
#	AUTO_BACKUP_MODE=$(READ_FROM_CONFIG_FILE "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" AUTO_BACKUP_MODE)

	# Adds profile name to the screen session to make sure it doesn't collide with other profiles
	SCREEN_SESSION_NAME=$DEFAULT_SCREEN_SESSION_NAME-$SERVER_PROFILE_NAME
}

function RESET_WARNINGS () {
	#This changes to TRUE when something makes turning the server on impossible. Like when it can't find server folder, or server jar file
	IMPOSSIBLE_TO_RUN="FALSE"
	CANNOT_FIND_SERVER_FOLDER="FALSE"
}

#Function to display the warnings
function DISPLAY_WARNINGS () {

		#Shows the warnings if it's necessary
		if [ ! -d "$BACKUP_FOLDER" ];
		then
		    echo -e "${C_RED}Warning! Couldn't find the backup folder!${C_ESC}"
		fi

		if [ ! -d "$SERVER_FOLDER" ];
		then
		    echo -e "${C_RED}Warning! couldn't find the server folder!${C_ESC}"
			IMPOSSIBLE_TO_RUN="TRUE"
			CANNOT_FIND_SERVER_FOLDER="TRUE"
		fi

		if [ ! -f "$SERVER_FOLDER/$SERVER_JAR_FILE" ];
		then
		    echo -e "${C_RED}Warning! Couldn't find the JAR file!${C_ESC}"
			IMPOSSIBLE_TO_RUN="TRUE"
		fi

		if [[ "$CUSTOM_JAVA_PATH_ENABLED" = "TRUE" ]]; then
			if [ ! -f "$CUSTOM_JAVA_PATH/java" ];
			then
				echo -e "${C_RED}Warning! Couldn't find Java in provided path!${C_ESC}"
				IMPOSSIBLE_TO_RUN="TRUE"
			fi
		fi

	echo
		#Shows warnings about configuration files
		if [ ! -f "$CONFIG_FILES_FOLDER/$SERVER_PROFILE_NAME.profile" ];
		then
		    echo -e "${C_RED}Warning! Couldn't find a configuration file ($SERVER_PROFILE_NAME.profile)!${C_ESC}"
		fi
}

#Debug mode display. Shows the variables
function DEBUG_MODE_DISPLAY () {
    if [ "$DEBUG_MODE" = "TRUE" ]; then
        echo "Debug mode enabled"
        echo "Used variables and their values:"

        echo " -- predefined"
        echo "VERSION -                               $VERSION"
        echo "CONFIG_FILES_FOLDER -                   $CONFIG_FILES_FOLDER"
        echo "SERVER_STATUS -                         $SERVER_STATUS"
		echo "DEFAULT_SCREEN_SESSION_NAME -           $DEFAULT_SCREEN_SESSION_NAME"
        echo "SCREEN_SESSION_NAME -                   $SCREEN_SESSION_NAME"
        echo "COMPRESSION_MODE -                      $COMPRESSION_MODE"
        echo "SERVER_BACKUP_FILE_NAME -               $SERVER_BACKUP_FILE_NAME"
        echo "SERVER_CONFIGURATION_BACKUP_FILE_NAME - $SERVER_CONFIGURATION_BACKUP_FILE_NAME"
        echo "CUSTOM_JAVA_PATH_ENABLED -              $CUSTOM_JAVA_PATH_ENABLED"
        echo "CUSTOM_JAVA_PATH -                      $CUSTOM_JAVA_PATH"

        echo "-- config related"
        echo "SERVER_GUI -                            $SERVER_GUI"

        echo "-- internal"
        echo "IMPOSSIBLE_TO_RUN -                     $IMPOSSIBLE_TO_RUN"
        echo "DISPLAY_SERVER_SIZE -                   $DISPLAY_SERVER_SIZE"
        echo "DISPLAY_BACKUP_SIZE -                   $DISPLAY_BACKUP_SIZE"
        echo "SERVER_PROFILE_NAME -                   $SERVER_PROFILE_NAME"

		echo "-- picker specific"
		echo "S_PICKER_SERVER_STATUS -                $S_PICKER_SERVER_STATUS"
		echo "SERVER_PICKER_MENU -                    $SERVER_PICKER_MENU"
fi
}

#Function to calculate and display host machine RAM usage
function CALCULATE_AND_DISPLAY_HOST_RAM_USAGE () {
    # Define what is low, mid and high RAM usage (in percents)
    RAM_USAGE_LOW="35"
    RAM_USAGE_MID="65"
    RAM_USAGE_HIGH="100"

    # Display results in nice readable way
    function DISPLAY_RESULTS () {
        echo -e "Host machine RAM usage: ${USED_RAM}MB of ${TOTAL_RAM}MB ($(COLOR_RAM_USAGE_PERCENTAGE))"
    }

    # Calculate RAM usage.
    # Gets value in KB, then divides by 1024 to get value in MB
    function CALCULATE_RAM_USAGE () {
        # Gets values from /proc/meminfo
        TOTAL_RAM=$(grep -m1 'MemTotal:' /proc/meminfo | awk '{print $2}')
        FREE_RAM=$(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}')

        # Converts TOTAL_RAM value to MB
        TOTAL_RAM=$(( $TOTAL_RAM / 1024 ))

        # Converts FREE_RAM value to MB
        FREE_RAM=$(( $FREE_RAM / 1024 ))

        # USED_RAM is total amount of RAM - free RAM
        USED_RAM=$(( $TOTAL_RAM - $FREE_RAM ))

        # Calculate percentage of free RAM
        USED_RAM_PERCENTAGE=$(( $USED_RAM * 100 / $TOTAL_RAM ))
    }

    function COLOR_RAM_USAGE_PERCENTAGE () {
        if [ $USED_RAM_PERCENTAGE -le $RAM_USAGE_LOW ]; then
            # Color to green
            echo -e "\e[92m$USED_RAM_PERCENTAGE%\e[0m"
            return
        fi

        if [ $USED_RAM_PERCENTAGE -le $RAM_USAGE_MID ]; then
            # Color to yellow
            echo -e "\e[93m$USED_RAM_PERCENTAGE%\e[0m"
            return
        fi

        if [ $USED_RAM_PERCENTAGE -le $RAM_USAGE_HIGH ]; then
            # Color to red
            echo -e "\e[91m$USED_RAM_PERCENTAGE%\e[0m"
            return
        fi
    }

    # Code
    CALCULATE_RAM_USAGE
    DISPLAY_RESULTS
}