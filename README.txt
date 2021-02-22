=======================================
DHCP IP-MAC Finder by Geoff Clark
VERSION 1.0.0 / 2021.02.21
=======================================

SUPPORT THE DEVELOPMENT OF THIS APP @ 

 https://www.patreon.com/clarktribegames
 https://paypal.me/aznblusuazn

JOIN THE COMMUNITY ON FACEBOOK OR DISCORD

  https://facebook.com/clarktribe.games
  https://discord.gg/6kW4der

=======================================

This program was written with PowerShell v2.0.  It should run on PSv1, but PSv2+ is recommended.

Also, it may be required to run "Set-ExecutionPolicy Unrestricted" in a PowerShell as Admin window first.

======================================

ABOUT THIS APPLICATION

This script was developed to help make the process of finding IP/MAC addresses on a DHCP server easier.

Current Features:

- gui for easier end user experience
- ability to pull scopes directly from the DHCP server
- ability to import DHCP export from a tab delimited text file
- built in code to copy/paste onto DHCP server if export is needed
- button to open notepad and auto paste for ease
- script will intelligently look at what source info user puts in (ip/mac) and define what the user is looking for
- mac address decoder will remove symbols and detect multiple mac address formats
- copy to clipboard button for ease of use
- clear and reset buttons for quick access
- bad address/invalid mac formats on found items can be detected
- invalid entries for source info can be detected

Future Features:

- detection of ip subnet ranges above 255 will notify the user they are invalid
- detection of non hexadecimal mac address entries will notify user they are invalid
- fix rare error when cancelling out of open file dialog

Copy of this code without the content of the Author is prohibited.

Contact the author:  info@clarktribegames.com

====================================