# Cubes - a launcher for Minecraft server
Cubes is wrote entirely in Bash. It's supposed to help you with managing your Minecraft server(s).

I tested it only on Ubuntu. I provide deb package only, but it should work just fine on other distros.

Main features:
- Manage up to 10 servers independently from each other (can be easily coded to add more)
- Make and restore backups of the servers
- Use custom java path if necessary
- Send commands to the server
- Optional support for GUI parts like file picker (Zenity) or text editor
- Cubes can detect if something isn't right and show appropriate information
- Can work on x86 and arm, and possibly more architectures (untested)

Cubes depends on:
 - p7zip - for backup features (archiving and extracting files)
 - screen - to let you manage all the servers separately and in easy way
 - nano - for editing configuration files directly from the launcher [this is only optional but highly recommended]

Note: This is only my side hobby project. It's not professional in any way!
It's provided 'as is'. I don't take responsibility for any actions of this software!
Dislaimer: THIS IS NOT AN OFFICIAL MINECRAFT PRODUCT. IT IS NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT


# Screenshots
![main menu](https://github.com/limoncia/Cubes/blob/main/readme%20screenshots/when%20offline.png)
![profile picker](https://github.com/limoncia/Cubes/blob/main/readme%20screenshots/profile%20picker.png)
![main menu when the server is running](https://github.com/limoncia/Cubes/blob/main/readme%20screenshots/when%20online.png)
![error when something's wrong](https://github.com/limoncia/Cubes/blob/main/readme%20screenshots/in%20case%20of%20an%20error%20it%20wont%20let%20you%20turn%20the%20server%20on.png)
